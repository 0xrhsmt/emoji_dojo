use array::ArrayTrait;


#[derive(Copy, Drop, Serde)]
enum MonsterCatchResult {
    Missed: (),
    Caught: (),
    Fled: (),
}

#[derive(Copy, Drop, Serde)]
enum MonsterType {
    None: (),
    Eagle: (),
    Rat: (),
    Caterpillar: (),
}
fn raffle_monster_type(seed: u256) -> MonsterType {
    let seed_value = seed % 3;
    if seed_value == 0 {
        MonsterType::Eagle(())
    } else if seed_value == 1 {
        MonsterType::Rat(())
    } else if seed_value == 2 {
        MonsterType::Caterpillar(())
    } else {
        MonsterType::None(())
    }
}

#[derive(Copy, Drop, Serde)]
enum TerrainType {
    None: (),
    TallGrass: (),
    Boulder: (),
}


#[derive(Component, Copy, Drop, Serde)]
struct Encounter {
    exists: bool,
    monster: felt252,
    catch_attempts: u128,
}

#[derive(Component, Copy, Drop, Serde)]
struct EncounterTrigger {
    is_enabled: bool,
}

#[derive(Component, Copy, Drop, Serde)]
struct Map {
    width: u32,
    height: u32,
}

#[derive(Component, Copy, Drop, Serde)]
struct MonsterCatchAttempt {
    result: MonsterCatchResult,
}

#[derive(Component, Copy, Drop, Serde)]
struct Movable {
    is_enabled: bool,
}

#[derive(Component, Copy, Drop, Serde)]
struct Monster {
    monster_type: MonsterType,
}

#[derive(Component, Copy, Drop, Serde)]
struct Encounterable {
    is_enabled: bool,
}

#[derive(Component, Copy, Drop, Serde)]
struct Obstruction {
    is_enabled: bool,
}

#[derive(Component, Copy, Drop, Serde)]
struct OwnedBy {
    player: felt252,
}

#[derive(Component, Copy, Drop, Serde)]
struct Player {
    is_enabled: bool,
}

#[derive(Component, Copy, Drop, Serde)]
struct Position {
    x: u32,
    y: u32
}

trait PositionTrait {
    fn distance(self: Position, other: Position) -> u32;
}

impl PositionImpl of PositionTrait {
    fn distance(self: Position, other: Position) -> u32 {
        let deltaX = if self.x > other.x {
            self.x - other.x
        } else {
            other.x - self.x
        };
        let deltaY = if self.y > other.y {
            self.x - other.y
        } else {
            other.y - self.y
        };

        deltaX + deltaY
    }
}

#[test]
#[available_gas(100000)]
fn test_position_distance() {
    assert(
        PositionTrait::distance(Position { x: 0, y: 0 }, Position { x: 0, y: 0 }) == 0, 'not zero'
    );
    assert(
        PositionTrait::distance(Position { x: 1, y: 0 }, Position { x: 0, y: 0 }) == 1, 'not zero'
    );
    assert(
        PositionTrait::distance(Position { x: 0, y: 0 }, Position { x: 1, y: 0 }) == 1, 'not zero'
    );
    assert(
        PositionTrait::distance(Position { x: 1, y: 1 }, Position { x: 0, y: 0 }) == 2, 'not zero'
    );
}
