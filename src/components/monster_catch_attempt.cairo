#[derive(Copy, Drop, Serde)]
enum MonsterCatchResult {
    Missed: (),
    Caught: (),
    Fled: (),
}

#[derive(Component, Copy, Drop, Serde)]
struct MonsterCatchAttempt {
    result: MonsterCatchResult,
}