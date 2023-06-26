#[derive(Component, Copy, Drop, Serde)]
struct Encounter {
    exists: bool,
    monster: felt252,
    catch_attempts: u128,
}