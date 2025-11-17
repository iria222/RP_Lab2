import sys

def convert_taxi_map_to_facts(input_file, output_file):
    """
    Reads a taxi route map from input_file and writes ASP facts
    for a telingo planning problem to output_file.
    """
    try:
        with open(input_file, 'r') as f:
            # Read all lines and strip whitespace
            board_lines = [line.strip() for line in f.readlines()]
    except FileNotFoundError:
        print(f"Error: The file '{input_file}' was not found.")
        sys.exit(1)

    # Check for empty file
    if not board_lines:
        print(f"Error: The input file '{input_file}' is empty.")
        sys.exit(1)

    # Get grid dimensions
    n = len(board_lines) # rows
    m = len(board_lines[0]) # cols
    
    if m == 0:
        print(f"Error: The input file '{input_file}' contains empty lines.")
        sys.exit(1)

    # Data structures to store parsed objects
    taxis = set()
    passengers = set()
    stations = []
    buildings = []
    taxi_locs = {}   # {taxi_id: (r, c)}
    pass_locs = {}   # {pass_id: (r, c)}

    # Parse the grid
    for r, line in enumerate(board_lines):
        # Ensure the grid is rectangular
        if len(line) != m:
            print(f"Error: Line {r} (0-indexed) has length {len(line)}, but expected {m}.")
            print(f"Ensure the grid is rectangular.")
            sys.exit(1)
            
        for c, char in enumerate(line):
            if '1' <= char <= '9':
                # It's a taxi
                taxi_id = int(char)
                if taxi_id in taxis:
                    print(f"Error: Duplicate taxi '{taxi_id}' found at ({r},{c}).")
                    sys.exit(1)
                taxis.add(taxi_id)
                taxi_locs[taxi_id] = (r, c)
            elif 'a' <= char <= 'z':
                # It's a passenger
                pass_id = char
                if pass_id in passengers:
                    print(f"Error: Duplicate passenger '{pass_id}' found at ({r},{c}).")
                    sys.exit(1)
                passengers.add(pass_id)
                pass_locs[pass_id] = (r, c)
            elif char == 'X':
                # It's a station
                stations.append((r, c))
            elif char == '#':
                # It's a building
                buildings.append((r, c))
            elif char == '.':
                # It's an empty cell, do nothing
                pass
            else:
                # Warn about any other character
                print(f"Warning: Unrecognized character '{char}' at ({r},{c}). Treating as empty cell.")

    num_taxis = len(taxis)
    num_pass = len(passengers)
    num_stations = len(stations)
    
    # Check problem constraint
    if num_stations < num_pass:
        print(f"Warning: There are {num_pass} passengers but only {num_stations} stations.")
        print("This problem may have no solution.")

    # Write the ASP facts to the output file
    try:
        with open(output_file, 'w') as f_out:

            # --- Dimensions ---
            f_out.write("% --- Dimensions ---\n")
            f_out.write(f"rows({n}).\n")
            f_out.write(f"cols({m}).\n\n")

            # --- Constants ---
            f_out.write("% --- Constants ---\n")
            f_out.write(f"#const num_taxis = {num_taxis}.\n")
            f_out.write(f"#const num_pass = {num_pass}.\n")
            f_out.write(f"#const num_stations = {num_stations}.\n\n")

            # --- Static Facts (domain) ---
            f_out.write("% --- Facts ---\n")
            
            for t in sorted(list(taxis)):
                f_out.write(f"taxi({t}).\n")
            
            for p in sorted(list(passengers)):
                f_out.write(f"passenger({p}).\n")
            
            for r in range(n):
                for c in range(m):
                    f_out.write(f"cell({r},{c}).\n")

            for r, c in stations:
                f_out.write(f"station({r},{c}).\n")
            
            for r, c in buildings:
                f_out.write(f"building({r},{c}).\n")

            # --- Initial State (Time 0) ---
            
            f_out.write("% Taxi locations\n")
            # Sort keys for consistent output
            for t in sorted(taxi_locs.keys()):
                r, c = taxi_locs[t]
                f_out.write(f"holds(at(taxi({t}),{r},{c}),0).\n")
            
            f_out.write("\n% Passenger locations\n")
            # Sort keys for consistent output
            for p in sorted(pass_locs.keys()):
                r, c = pass_locs[p]
                f_out.write(f"holds(at(pass({p}),{r},{c}),0).\n")
                
            f_out.write("\n% Taxi status\n")
            for t in sorted(list(taxis)):
                f_out.write(f"holds(free(taxi({t})),0).\n")
            

    except IOError:
        print(f"Error: Could not write to output file '{output_file}'.")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Use: python3 encode.py <input_file> <output_file>")
        print("Example: python3 encode.py domain.txt domain.lp")
        sys.exit(1)

    input_file_path = sys.argv[1]
    output_file_path = sys.argv[2]
    
    convert_taxi_map_to_facts(input_file_path, output_file_path)
    print(f"Successfully converted '{input_file_path}' to '{output_file_path}'.")