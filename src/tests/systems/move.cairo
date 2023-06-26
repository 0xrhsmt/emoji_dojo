use traits::Into;
use array::{ArrayTrait, SpanTrait};

use starknet::{ContractAddress};
use dojo_core::interfaces::{
    IWorldDispatcher, IWorldDispatcherTrait
};

use emoji_dojo::systems::move::{ Move };
use emoji_dojo::tests::systems::world::{spawn_world};
use emoji_dojo::tests::systems::spawn::{spawn_player};
use emoji_dojo::tests::systems::map_seed::{map_seed};

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
fn test_move() {
    let (world_address,) = spawn_world();
    let (map_id, _, _,) = map_seed(world_address, 5, 5);
    let (_, ) = spawn_player(world_address, 2, 2);

    move(world_address, 2, 3);
}
