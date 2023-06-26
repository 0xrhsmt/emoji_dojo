use traits::Into;
use array::{ArrayTrait, SpanTrait};
use option::OptionTrait;

use starknet::{ContractAddress};

use dojo_core::interfaces::{
    IWorldDispatcher, IWorldDispatcherTrait
};
use emoji_dojo::systems::spawn::{ Spawn };
use emoji_dojo::tests::systems::world::{spawn_world};
use emoji_dojo::tests::systems::map_seed::{map_seed};

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
