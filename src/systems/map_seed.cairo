#[system]
mod MapSeed {
    use array::ArrayTrait;
    use traits::Into;

    use emoji_dojo::components::encounter_trigger::{ EncounterTrigger };
    use emoji_dojo::components::map::{ Map };
    use emoji_dojo::components::player::{ Player };
    use emoji_dojo::components::obstruction::{ Obstruction };
    use emoji_dojo::components::position::{ Position };
    use emoji_dojo::constants::{SINGLETON_ENTITY_ID};

    fn execute(ctx: Context, width: u32, height: u32) -> (felt252, u32, u32,) {
        assert(width > 0, 'width must be greater than 0');
        assert(height > 0, 'height must be greater than 0');

        let map_id = SINGLETON_ENTITY_ID;
        let map_sk: Query = map_id.into();
        let map = commands::<Map>::try_entity(map_sk);
        assert(map.is_none(), 'already initialized');

        commands::set_entity(map_sk, ( Map { width, height }, ));

        let mut x = 0;
        let mut y = 0;
        loop {
            if y >= height {
                break ();
            }
            loop {
                if x >= width {
                    break ();
                }
                if x == 0 | y == 0 | x == width - 1 | y == height - 1 {
                    commands::set_entity(
                        (x, y).into(), ( Position { x, y }, Obstruction { is_enabled: true }, )
                    );
                } else if x % 2 == 0 & y % 3 == 0 {
                    commands::set_entity(
                        (x, y).into(), ( Position { x, y }, EncounterTrigger { is_enabled: true },  )
                    );
                };

                x += 1;
            }
            x = 0;
            y += 1;
        }

        (map_id, width, height,)
    }
}
