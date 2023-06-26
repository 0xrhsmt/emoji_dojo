use traits::Into;
use array::{ArrayTrait, SpanTrait};
use option::OptionTrait;

use starknet::{ContractAddress};

use dojo_core::interfaces::{
    IWorldDispatcher, IWorldDispatcherTrait
};
use emoji_dojo::systems::map_seed::{ MapSeed };
use emoji_dojo::tests::systems::world::{ spawn_world };

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