use traits::Into;
use array::{ArrayTrait};

use starknet::{ContractAddress};

use dojo_core::test_utils::spawn_test_world;
use dojo_core::auth::systems::{RouteTrait};
use emoji_dojo::components::encounter::{EncounterComponent};
use emoji_dojo::components::encounter_trigger::{EncounterTriggerComponent };
use emoji_dojo::components::map::{MapComponent};
use emoji_dojo::components::monster_catch_attempt::{MonsterCatchAttemptComponent};
use emoji_dojo::components::movable::{MovableComponent};
use emoji_dojo::components::monster::{MonsterComponent};
use emoji_dojo::components::encounterable::{EncounterableComponent};
use emoji_dojo::components::obstruction::{ObstructionComponent};
use emoji_dojo::components::owned_by::{OwnedByComponent};
use emoji_dojo::components::player::{PlayerComponent};
use emoji_dojo::components::position::{PositionComponent};
use emoji_dojo::systems::map_seed::{MapSeed};
use emoji_dojo::systems::spawn::{Spawn};
use emoji_dojo::systems::move::{Move};

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
