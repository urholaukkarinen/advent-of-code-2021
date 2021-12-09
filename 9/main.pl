# Read input into a one-dimensional array
open f, '<', 'input.txt' or die;
@input = <f>;
$width = length(@input[0])-2;
$height = @input;
$input = join('', @input);
$input =~ s/\R*//g;
@input = split(//, $input);

# Get a list of neighbor indices for given index
sub neighbors {
    ($i) = @_;
    @a = ();
    $x = $i % $width;
    $y = int($i / $width);

    if ($x > 0) {
        push @a, $i-1;
    }
    if ($y > 0) {
        push @a, $i-$width;
    }
    if ($x < $width-1) {
        push @a, $i+1;
    }
    if ($y < $height-1) {
        push @a, $i+$width;
    }

    return @a;
}

# Find low points
@lowest = ();
for my $i (0..$width*$height-1) {
    if (@input[$i] != 9 && !grep { @input[$_] < @input[$i] } neighbors($i)) {
        push @lowest, $i;
    }
}

# Calculate sum of risk levels
$partOne = 0;
foreach (@lowest) {
    $partOne += @input[$_]+1;
}

# Calculate basin sizes
@basinSizes = ();
foreach (@lowest) {
    @toVisit = ($_);
    $size = 0;

    while (@toVisit) {
        $i = pop(@toVisit);
        $val = @input[$i];
        
        if ($val != 9) {
            $size += 1;
            $input[$i] = 9;
            push(@toVisit, neighbors($i));
        }
    }

    push(@basinSizes, int($size));
}
@basinSizes = sort {$a < $b} @basinSizes;

$partTwo = 1;
foreach (0..2) {
    $partTwo *= @basinSizes[$_];
}

print "$partOne\n$partTwo\n";