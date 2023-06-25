#[system]
mod MapSeed {
    use array::ArrayTrait;
    use traits::Into;

    use emoji_dojo::components::{Player, Position, Map, EncounterTrigger, Obstruction, TerrainType};
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

#[system]
mod Spawn {
    use array::ArrayTrait;
    use traits::Into;

    use emoji_dojo::components::{Player, Position, Map, Obstruction, Movable, Encounterable};
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

#[system]
mod Move {
    use array::ArrayTrait;
    use traits::Into;
    use debug::PrintTrait;
    use box::BoxTrait;

    use emoji_dojo::components::{Movable, Position, PositionTrait, Encounter, Map, Obstruction, Encounterable, EncounterTrigger, Monster, MonsterType, };
    use emoji_dojo::components::raffle_monster_type;
    use emoji_dojo::constants::{SINGLETON_ENTITY_ID};

    const encounter_chance: u8 = 20;

    // note: ignore linting of Context and commands
    fn execute(ctx: Context, x: u32, y: u32) -> bool {
        let player_id: felt252 = ctx.caller_account.into();
        let player_sk: Query = player_id.into();

        let movable = commands::<Movable>::entity(player_sk);
        assert(movable.is_enabled == true, 'player is not movable');

        let encounter = commands::<Encounter>::try_entity(player_sk);
        assert(encounter.is_none(), 'player is in encounter');

        let position = commands::<Position>::entity(player_sk);
        let new_position = Position { x, y };
        assert(position.distance(new_position) == 1, 'move 1 space');

        let map = commands::<Map>::entity(SINGLETON_ENTITY_ID.into());
        let position_x = x % map.width;
        let position_y = y % map.height;
        let position_sk: Query = (position_x, position_y).into();

        let obstruction = commands::<Obstruction>::try_entity(position_sk);
        assert(obstruction.is_none(), 'this space is obstructed');

        commands::set_entity(
            player_sk, ( Position { x: position_x, y: position_y }, )
        );

        let encounterable_option = commands::<Encounterable>::try_entity(player_sk);
        let is_encounterable = match encounterable_option {
            Option::Some(encounterable) => encounterable.is_enabled == true,
            Option::None(_) => false,
        };
        let encounter_trigger_option = commands::<EncounterTrigger>::try_entity(position_sk);
        let is_encounter_triggered = match encounter_trigger_option {
            Option::Some(encounter_trigger) => encounter_trigger.is_enabled == true,
            Option::None(_) => false,
        };
        if !is_encounterable | !is_encounter_triggered {
            return false;
        }

        let seed = starknet::get_tx_info().unbox().transaction_hash;
        if occurs(seed, encounter_chance) {
            let monster_id: felt252 = seed + player_id;
            let monster_sk: Query = monster_id.into();
            let monster_type: MonsterType = raffle_monster_type(monster_id.into());
            let player_sk: Query = player_id.into();

            commands::set_entity(
                monster_sk, ( Monster { monster_type } , )
            );
            commands::set_entity(
                player_sk, ( Encounter { exists: true, monster: monster_id, catch_attempts: 0 }, )
            );
        }

        true
    }

    fn occurs(seed: felt252, likelihood: u8) -> bool {
        let seed: u256 = seed.into();
        let result: u128 = seed.low % 100;
        
        result <= likelihood.into()
    }
 
}


