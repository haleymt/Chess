class ChessError < Exception ; end
class NoPieceThere < ChessError ; end
class OutOfBoard < ChessError ; end
class MovedIntoCheck < ChessError ; end
class ThatsNotYours < ChessError ; end
class InvalidMove < ChessError ; end
class BlockedMove < ChessError ; end
class NotEnoughElements < ChessError ; end
