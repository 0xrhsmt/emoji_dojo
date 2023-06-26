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
