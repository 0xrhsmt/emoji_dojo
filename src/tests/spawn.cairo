use traits::Into;
use array::{ArrayTrait, SpanTrait};
use option::OptionTrait;

use starknet::{ContractAddress};

use dojo_core::test_utils::spawn_test_world;
use dojo_core::auth::systems::{RouteTrait};
use dojo_core::interfaces::{
    IWorldDispatcher, IWorldDispatcherTrait
};
use emoji_dojo::components::{Encounter, EncounterComponent};
use emoji_dojo::components::{EncounterTrigger, EncounterTriggerComponent};
use emoji_dojo::components::{Map, MapComponent};
use emoji_dojo::components::{MonsterCatchAttempt, MonsterCatchAttemptComponent};
use emoji_dojo::components::{Movable, MovableComponent};
use emoji_dojo::components::{Monster, MonsterComponent};
use emoji_dojo::components::{Encounterable, EncounterableComponent};
use emoji_dojo::components::{Obstruction, ObstructionComponent};
use emoji_dojo::components::{OwnedBy, OwnedByComponent};
use emoji_dojo::components::{Player, PlayerComponent};
use emoji_dojo::components::{Position, PositionComponent};

use emoji_dojo::systems::{MapSeed, Spawn, Move};
use emoji_dojo::constants::{SINGLETON_ENTITY_ID};

fn spawn_world() -> (ContractAddress,) {
    let mut components = ArrayTrait::new();
    components.append(EncounterComponent::TEST_CLASS_HASH);
    components.append(EncounterTriggerComponent::TEST_CLASS_HASH);
    components.append(MapComponent::TEST_CLASS_HASH);
    components.append(MonsterCatchAttemptComponent::TEST_CLASS_HASH);
    components.append(MovableComponent::TEST_CLASS_HASH);
    components.append(MonsterComponent::TEST_CLASS_HASH);
    components.append(EncounterableComponent::TEST_CLASS_HASH);
    components.append(ObstructionComponent::TEST_CLASS_HASH);
    components.append(OwnedByComponent::TEST_CLASS_HASH);
    components.append(PlayerComponent::TEST_CLASS_HASH);
    components.append(PositionComponent::TEST_CLASS_HASH);

    let mut systems = ArrayTrait::new();
    systems.append(MapSeed::TEST_CLASS_HASH);
    systems.append(Spawn::TEST_CLASS_HASH);
    systems.append(Move::TEST_CLASS_HASH);

    let mut routes = ArrayTrait::new();
    routes.append(RouteTrait::new('MapSeed'.into(), 'MapWriter'.into(), 'Map'.into()));
    routes.append(RouteTrait::new('MapSeed'.into(), 'PositionWriter'.into(), 'Position'.into()));
    routes.append(RouteTrait::new('MapSeed'.into(), 'EncounterTriggerWriter'.into(), 'EncounterTrigger'.into()));
    routes.append(RouteTrait::new('MapSeed'.into(), 'ObstructionWriter'.into(), 'Obstruction'.into()));
    routes.append(RouteTrait::new('Spawn'.into(), 'PositionWriter'.into(), 'Position'.into()));
    routes.append(RouteTrait::new('Spawn'.into(), 'PlayerWriter'.into(), 'Player'.into()));
    routes.append(RouteTrait::new('Spawn'.into(), 'MovableWriter'.into(), 'Movable'.into()));
    routes.append(RouteTrait::new('Spawn'.into(), 'EncounterableWriter'.into(), 'Encounterable'.into()));
    routes.append(RouteTrait::new('Move'.into(), 'PositionWriter'.into(), 'Position'.into()));
    routes.append(RouteTrait::new('Move'.into(), 'MonsterWriter'.into(), 'Monster'.into()));
    routes.append(RouteTrait::new('Move'.into(), 'EncounterWriter'.into(), 'Encounter'.into()));

    let world = spawn_test_world(components, systems, routes);

    (world.contract_address,)
}

fn map_seed(world_address: ContractAddress, width: u32, height: u32) -> (felt252, u32, u32,) {
    let mut map_seed_calldata = ArrayTrait::<felt252>::new();
    map_seed_calldata.append(width.into());
    map_seed_calldata.append(height.into());

    let mut res = IWorldDispatcher {
        contract_address: world_address
    }.execute('MapSeed'.into(), map_seed_calldata.span());

    assert(res.len() > 0, 'did not seed');

    let (map_id, width, height,) = serde::Serde::<(felt252, u32, u32,)>::deserialize(ref res)
        .expect('spawn deserialization failed');
    
    (map_id, width, height,)
}

fn spawn_player(world_address: ContractAddress, x: u32, y: u32) -> (felt252,) {
    let mut spawn_player_calldata = ArrayTrait::<felt252>::new();
    spawn_player_calldata.append(x.into());
    spawn_player_calldata.append(y.into());

    let mut res = IWorldDispatcher {
        contract_address: world_address
    }.execute('Spawn'.into(), spawn_player_calldata.span());

    assert(res.len() > 0, 'did not spawn');

    let (player_id) = serde::Serde::<(felt252,)>::deserialize(ref res)
        .expect('spawn deserialization failed');

    (player_id, )
}


fn move(world_address: ContractAddress, x: u32, y: u32) {
    let mut move_calldata = ArrayTrait::<felt252>::new();
    move_calldata.append(x.into());
    move_calldata.append(y.into());

    let mut res = IWorldDispatcher {
        contract_address: world_address
    }.execute('Move'.into(), move_calldata.span());
    assert(res.len() > 0, 'did not move');
}

#[test]
#[available_gas(1000000000)]
fn test_map_seed() {
    let (world_address,) = spawn_world();
    let (map_id, _, _,) = map_seed(world_address, 5, 5);

    let mut res = IWorldDispatcher {
        contract_address: world_address
    }.entity('Map'.into(), (map_id, ).into(), 0, 0);
    assert(res.len() > 0, 'map not found');

    let (width, height) = serde::Serde::<(u32, u32)>::deserialize(ref res)
        .expect('map deserialization failed');
    assert(width == 5, 'x not equal');
    assert(height == 5, 'y not equal');
}

#[test]
#[available_gas(1000000000)]
fn test_spawn_player() {
    let (world_address,) = spawn_world();
    let (map_id, _, _,) = map_seed(world_address, 5, 5);
    let (player_id, ) = spawn_player(world_address, 1, 1);

    let mut res = IWorldDispatcher {
        contract_address: world_address
    }.entity('Player'.into(), (player_id, ).into(), 0, 0);
    let (is_enabled,) = serde::Serde::<(bool,)>::deserialize(ref res)
        .expect('player deserialization failed');
    assert(is_enabled == true, 'player not enabled');

    let mut res = IWorldDispatcher {
        contract_address: world_address
    }.entity('Movable'.into(), (player_id, ).into(), 0, 0);
    let (is_enabled,) = serde::Serde::<(bool,)>::deserialize(ref res)
        .expect('movable deserialization failed');
    assert(is_enabled == true, 'movable not enabled');

    let mut res = IWorldDispatcher {
        contract_address: world_address
    }.entity('Encounterable'.into(), (player_id, ).into(), 0, 0);
    let (is_enabled,) = serde::Serde::<(bool,)>::deserialize(ref res)
        .expect('deserialization failed');
    assert(is_enabled == true, 'Encounterable not enabled');

    let mut res = IWorldDispatcher {
        contract_address: world_address
    }.entity('Position'.into(), (player_id, ).into(), 0, 0);
    let (x, y) = serde::Serde::<(u32,u32)>::deserialize(ref res)
        .expect('position deserialization failed');
    assert(x == 1, 'x not equal');
    assert(y == 1, 'y not equal');
}

#[test]
#[available_gas(1000000000)]
fn test_move() {
    let (world_address,) = spawn_world();
    let (map_id, _, _,) = map_seed(world_address, 5, 5);
    let (_, ) = spawn_player(world_address, 2, 2);

    move(world_address, 2, 3);
}
