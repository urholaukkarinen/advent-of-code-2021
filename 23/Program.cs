/// Brute-forces every single solution to the input and outputs the cheapest cost

static class Program
{
    private static void Main(string[] args)
    {
        var state = State.Load();
        // Part one
        Console.WriteLine(State.Recurse(state));

        // Part two
        state.SetupPartTwo();
        Console.WriteLine(State.Recurse(state));
    }
}

internal class State
{
    private static int _overallBestScore = int.MaxValue;

    private static readonly int[] CorridorSlots = { 1, 2, 4, 6, 8, 10, 11 };
    private readonly bool[,] _occupied = new bool[13, 13];
    private readonly int[] _holes;
    private List<Piece> _pieces;
    private int _score;

    State()
    {
        _holes = new int[4];
        _pieces = new List<Piece>();
    }

    private State(State other)
    {
        _holes = (int[])other._holes.Clone();
        _score = other._score;
        _pieces = other._pieces.Select(piece => (Piece)piece.Clone()).ToList();

        for (var i = 0; i < other._occupied.GetLength(0); i++)
        {
            for (var j = 0; j < other._occupied.GetLength(1); j++)
            {
                _occupied[i, j] = other._occupied[i, j];
            }
        }
    }

    internal static State Load()
    {
        var input = File.ReadAllLines("input.txt");

        var state = new State();

        for (var i = 0; i < 4; i++)
        {
            state._holes[i] = input.Length - 2;
        }

        var pieces = new List<Piece>();
        for (var x = 3; x < 10; x += 2)
        {
            for (var y = 0; y < input.Length; y++)
            {
                Piece piece;
                try
                {
                    piece = new Piece(input[y][x], x, y);
                }
                catch (ArgumentOutOfRangeException)
                {
                    continue;
                }

                state._occupied[x, y] = true;

                if (x == piece.Kind.HolePosition() && y == state._holes[(int)piece.Kind])
                {
                    state._holes[(int)piece.Kind] -= 1;
                }
                else
                {
                    pieces.Add(piece);
                }
            }
        }


        state._pieces = pieces;

        return state;
    }

    internal void SetupPartTwo()
    {
        _overallBestScore = Int32.MaxValue;

        foreach (var piece in _pieces.Where(piece => piece.Y == 3))
        {
            piece.Y = 5;
            _occupied[piece.X, piece.Y] = true;
        }

        for (var i = 0; i < _holes.Length; i++)
        {
            _holes[i] += 2;
        }

        var pieceIdx = 0;
        for (var y = 3; y < 5; y++)
        {
            for (var x = 3; x < 10; x += 2)
            {
                _occupied[x, y] = true;
                _pieces.Add(new Piece("DCBADBAC"[pieceIdx], x, y));

                pieceIdx += 1;
            }
        }
    }

    internal static int Recurse(State state)
    {
        if (state._score > _overallBestScore)
        {
            return int.MaxValue;
        }

        if (state._pieces.Count == 0)
        {
            if (state._score < _overallBestScore)
            {
                _overallBestScore = state._score;
            }

            return state._score;
        }

        var bestScore = int.MaxValue;

        for (var i = 0; i < state._pieces.Count; i++)
        {
            var piece = state._pieces[i];

            if (state.CanMoveToHole(piece))
            {
                var nextState = new State(state);
                nextState.MoveToHole(i);
                bestScore = Math.Min(bestScore, Recurse(nextState));
            }
            else if (piece.Y != 1)
            {
                foreach (var x in CorridorSlots.Where(x => state.CanMoveToCorridor(piece, x)))
                {
                    var nextState = new State(state);
                    nextState.MoveToCorridor(i, x);
                    bestScore = Math.Min(bestScore, Recurse(nextState));
                }
            }
        }

        return bestScore;
    }

    private void MoveToHole(int pieceIdx)
    {
        var piece = _pieces[pieceIdx];

        var targetX = piece.Kind.HolePosition();
        var targetY = _holes[(int)piece.Kind];

        _score += MoveCost(piece, targetX, targetY);

        _holes[(int)piece.Kind] -= 1;
        _occupied[targetX, targetY] = true;
        _occupied[piece.X, piece.Y] = false;
        _pieces.RemoveAt(pieceIdx);
    }
    private void MoveToCorridor(int pieceIdx, int x)
    {
        var piece = _pieces[pieceIdx];

        _score += MoveCost(piece, x, 1);
        _occupied[piece.X, piece.Y] = false;
        piece.X = x;
        piece.Y = 1;
        _occupied[piece.X, piece.Y] = true;
    }

    private static int MoveCost(Piece piece, int x, int y)
    {
        var steps = Math.Abs(piece.X - x) + Math.Abs(piece.Y - 1) + Math.Abs(y - 1);
        return steps * piece.Kind.MoveCost();
    }

    private bool CanMoveToCorridor(Piece piece, int slotX)
    {
        return piece.Y > 1 && !_occupied[piece.X, piece.Y - 1] && IsCorridorEmptyBetween(piece.X, slotX)
            && !_occupied[slotX, 1];
    }

    private bool CanMoveToHole(Piece piece)
    {
        if (piece.Y > 1 && _occupied[piece.X, piece.Y - 1] || !IsHoleFree(piece))
        {
            return false;
        }

        return IsCorridorEmptyBetween(piece.X, piece.Kind.HolePosition());
    }

    private bool IsCorridorEmptyBetween(int from, int to)
    {
        if (from > to)
        {
            (@from, to) = (to, @from);
        }

        return _pieces.All(piece => piece.Y != 1 || piece.X <= @from || piece.X >= to);
    }

    private bool IsHoleFree(Piece piece)
    {
        return !_occupied[piece.Kind.HolePosition(), _holes[(int)piece.Kind]];
    }
}

internal class Piece : ICloneable
{
    public PieceKind Kind { get; }
    public int X { get; set; }
    public int Y { get; set; }

    internal Piece(char c, int x, int y)
    {
        PieceKind kind;
        switch (c)
        {
            case 'A': kind = PieceKind.Amber; break;
            case 'B': kind = PieceKind.Bronze; break;
            case 'C': kind = PieceKind.Copper; break;
            case 'D': kind = PieceKind.Desert; break;
            default: throw new ArgumentOutOfRangeException();
        }

        Kind = kind;
        X = x;
        Y = y;
    }

    internal Piece(PieceKind kind, int x, int y)
    {
        Kind = kind;
        X = x;
        Y = y;
    }

    public object Clone()
    {
        return new Piece(Kind, X, Y);
    }

    public String Char()
    {
        return Kind switch
        {
            PieceKind.Amber => "A",
            PieceKind.Bronze => "B",
            PieceKind.Copper => "C",
            PieceKind.Desert => "D",
            _ => "#"
        };
    }
}

internal enum PieceKind
{
    Amber = 0,
    Bronze = 1,
    Copper = 2,
    Desert = 3,
}

internal static class PieceKindExt
{
    private static readonly int[] HolePositions = { 3, 5, 7, 9 };
    private static readonly int[] Costs = { 1, 10, 100, 1000 };
    internal static int HolePosition(this PieceKind pieceKind)
    {
        return HolePositions[(int)pieceKind];
    }

    internal static int MoveCost(this PieceKind pieceKind)
    {
        return Costs[(int)pieceKind];
    }
}
