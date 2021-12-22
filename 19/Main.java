import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * Brute-force solution to Day 19.
 */
public class Main {
    /// All 24 possible rotations as orders & signs
    private static final int[][] ROTATIONS = new int[][] {
            new int[] { 0, 1, 2, -1, -1, 1 },
            new int[] { 0, 1, 2, -1, 1, -1 },
            new int[] { 0, 1, 2, 1, -1, -1 },
            new int[] { 0, 1, 2, 1, 1, 1 },
            new int[] { 0, 2, 1, -1, -1, -1 },
            new int[] { 0, 2, 1, -1, 1, 1 },
            new int[] { 0, 2, 1, 1, -1, 1 },
            new int[] { 0, 2, 1, 1, 1, -1 },
            new int[] { 1, 0, 2, -1, -1, -1 },
            new int[] { 1, 0, 2, -1, 1, 1 },
            new int[] { 1, 0, 2, 1, -1, 1 },
            new int[] { 1, 0, 2, 1, 1, -1 },
            new int[] { 1, 2, 0, -1, -1, 1 },
            new int[] { 1, 2, 0, -1, 1, -1 },
            new int[] { 1, 2, 0, 1, -1, -1 },
            new int[] { 1, 2, 0, 1, 1, 1 },
            new int[] { 2, 0, 1, -1, -1, 1 },
            new int[] { 2, 0, 1, -1, 1, -1 },
            new int[] { 2, 0, 1, 1, -1, -1 },
            new int[] { 2, 0, 1, 1, 1, 1 },
            new int[] { 2, 1, 0, -1, -1, -1 },
            new int[] { 2, 1, 0, -1, 1, 1 },
            new int[] { 2, 1, 0, 1, -1, 1 },
            new int[] { 2, 1, 0, 1, 1, -1 },
    };

    private final List<Scanner> scanners = new ArrayList<>();
    private final HashMap<Integer, List<Overlap>> overlaps = new HashMap<>();
    private final List<List<Beacon>> origins = new ArrayList<>();

    public static void main(String[] args) throws IOException {
        new Main();
    }

    public Main() throws IOException {
        parseInput("input.txt").collect(
                Collectors.toCollection(() -> this.scanners));

        for (var i = 0; i < scanners.size(); i++) {
            var firstScanner = scanners.get(i);

            overlaps.putIfAbsent(i, new ArrayList<Overlap>());
            origins.add(new ArrayList<>());

            for (var j = 0; j < scanners.size(); j++) {
                if (i == j) {
                    continue;
                }

                for (var k = 0; k < ROTATIONS.length; k++) {
                    var secondScanner = scanners.get(j).rotated(ROTATIONS[k]);
                    var secondOrigin = firstScanner.findOverlap(secondScanner);

                    if (secondOrigin.isPresent()) {
                        var overlap = new Overlap(j, k, secondOrigin.get());
                        overlaps.get(i).add(overlap);

                        // System.out.printf("%d, %d, %s\n", i, j, secondOrigin.get());
                        break;
                    }
                }
            }
        }

        mergeScanners(0, new HashSet<>());

        var origs = origins.get(0);
        var maxDist = 0;

        for (var i = 0; i < origs.size(); i++) {
            var firstOrigin = origs.get(i);
            for (var j = 0; j < origs.size(); j++) {
                var secondOrigin = origs.get(j);

                maxDist = Math.max(maxDist, firstOrigin.getManhattanDistance(secondOrigin));
            }
        }

        // Part one
        System.out.println(scanners.get(0).numberOfUniqueBeacons());

        // Part two
        System.out.println(maxDist);
    }

    void mergeScanners(int i, HashSet<Integer> visited) {
        visited.add(i);

        var iOrigins = origins.get(i);
        for (var overlap : overlaps.get(i)) {
            if (visited.contains(overlap.scannerIndex)) {
                continue;
            }
            var j = overlap.scannerIndex;

            mergeScanners(j, new HashSet<>(visited));

            var rotation = ROTATIONS[overlap.rotationIndex];

            scanners.get(j).rotated(rotation).beacons.stream()
                    .map(b -> b.add(overlap.rotatedOrigin))
                    .collect(Collectors.toCollection(() -> scanners.get(i).beacons));
            scanners.get(j).beacons.clear();

            var jOrigins = origins.get(j);
            jOrigins.stream()
                    .map(p -> p.rotated(rotation).add(overlap.rotatedOrigin))
                    .collect(Collectors.toCollection(() -> iOrigins));
            jOrigins.clear();
            iOrigins.add(overlap.rotatedOrigin);

            // System.out.printf("%d -> %d\n", i, j);
        }

        overlaps.get(i).clear();
    }

    static record Overlap(int scannerIndex, int rotationIndex, Beacon rotatedOrigin) {
    }

    static Stream<Scanner> parseInput(String filename) throws IOException {
        return Arrays.stream(Files.readString(Path.of(filename)).split("\n\n"))
                .map(s -> s.split("---\n")[1].split("\n"))
                .map(beacons -> Arrays.stream(beacons).map(Beacon::fromString).collect(Collectors.toList()))
                .map(beacons -> new Scanner(beacons));
    }

    static class Scanner {
        private final List<Beacon> beacons;

        Scanner(final List<Beacon> beacons) {
            this.beacons = beacons;
        }

        int numberOfUniqueBeacons() {
            return new HashSet<>(beacons).size();
        }

        Scanner rotated(int[] rotation) {
            var rotatedBeacons = beacons.stream()
                    .map(beacon -> beacon.rotated(rotation))
                    .collect(Collectors.toList());

            return new Scanner(rotatedBeacons);
        }

        Optional<Beacon> findOverlap(Scanner other) {
            for (var a : this.beacons) {
                for (var b : other.beacons) {
                    var origin = a.sub(b);
                    var count = 0;

                    for (var c : other.beacons) {
                        if (this.beacons.contains(origin.add(c))) {
                            count += 1;
                        }

                        if (count >= 12) {
                            return Optional.of(origin);
                        }
                    }
                }
            }

            return Optional.empty();
        }
    }

    static class Beacon {
        final int[] coords;

        Beacon(int x, int y, int z) {
            this.coords = new int[] { x, y, z };
        }

        Beacon(int[] coords) {
            this.coords = coords;
        }

        static Beacon fromString(String str) {
            var coords = Arrays.stream(str.split(",")).map(val -> Integer.parseInt(val))
                    .collect(Collectors.toList());

            return new Beacon(coords.get(0), coords.get(1), coords.get(2));
        }

        int getX() {
            return coords[0];
        }

        int getY() {
            return coords[1];
        }

        int getZ() {
            return coords[2];
        }

        Beacon add(Beacon other) {
            return new Beacon(
                    this.getX() + other.getX(),
                    this.getY() + other.getY(),
                    this.getZ() + other.getZ());
        }

        Beacon sub(Beacon other) {
            return new Beacon(
                    this.getX() - other.getX(),
                    this.getY() - other.getY(),
                    this.getZ() - other.getZ());
        }

        Beacon rotated(int[] rotation) {
            return new Beacon(
                    this.coords[rotation[0]] * rotation[3],
                    this.coords[rotation[1]] * rotation[4],
                    this.coords[rotation[2]] * rotation[5]);
        }

        int getManhattanDistance(Beacon other) {
            return Math.abs(this.getX() - other.getX())
                    + Math.abs(this.getY() - other.getY())
                    + Math.abs(this.getZ() - other.getZ());
        }

        @Override
        public boolean equals(Object other) {
            return (other instanceof Beacon)
                    && Arrays.equals(this.coords, ((Beacon) other).coords);
        }

        @Override
        public String toString() {
            return Arrays.toString(this.coords);
        }

        @Override
        public int hashCode() {
            return Arrays.hashCode(coords);
        }
    }
}