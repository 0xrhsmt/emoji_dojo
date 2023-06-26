#[system]
mod Spawn {
    use array::ArrayTrait;
    use traits::Into;

    use emoji_dojo::components::map::{ Map };
    use emoji_dojo::components::movable::{ Movable };
    use emoji_dojo::components::player::{ Player };
    use emoji_dojo::components::obstruction::{ Obstruction };
    use emoji_dojo::components::encounterable::{ Encounterable };
    use emoji_dojo::components::position::{ Position };
    use emoji_dojo::constants::{SINGLETON_ENTITY_ID};

    fn execute(ctx: Context, x: u32, y: u32) -> (felt252,) {
        let player_id: felt252 = ctx.caller_account.into();
        let player_sk: Query = player_id.into();

        let player = commands::<Player>::try_entity(player_sk);
        assert(player.is_none(), 'already spawn');

        let map = commands::<Map>::entity(SINGLETON_ENTITY_ID.into());
        let position_x = x % map.width;
        let position_y = y % map.height;

        let obstruction = commands::<Obstruction>::try_entity((position_x, position_y).into());
        assert(obstruction.is_none(), 'this space is obstructed');

        let player = commands::set_entity(
            player_sk,( Player { is_enabled: true }, Movable { is_enabled: true }, Encounterable { is_enabled: true }, Position { x: position_x, y: position_y }, )
        );

        (player_id,)
    }
}
