#[derive(Copy, Drop, Serde)]
enum MonsterType {
    None: (),
    Eagle: (),
    Rat: (),
    Caterpillar: (),
}

#[derive(Component, Copy, Drop, Serde)]
struct Monster {
    monster_type: MonsterType,
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