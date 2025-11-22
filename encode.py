import sys

def convert_taxi_map_to_facts(input_file, output_file):
    try:
        with open(input_file, 'r') as f:
            board_lines = [line.strip() for line in f.readlines()]
    except FileNotFoundError:
        print(f"Error: File '{input_file}' not found.")
        sys.exit(1)

    if not board_lines:
        print("Error: Input file is empty.")
        sys.exit(1)

    n = len(board_lines)
    m = len(board_lines[0])
    
    taxis = set()
    passengers = set()
    stations = []
    buildings = []
    taxi_locs = {}
    pass_locs = {}

    for r, line in enumerate(board_lines):
        if len(line) != m:
            print(f"Error: Grid not rectangular.")
            sys.exit(1)
        for c, char in enumerate(line):
            if '1' <= char <= '9':
                taxi_id = int(char)
                taxis.add(taxi_id)
                taxi_locs[taxi_id] = (r, c)
            elif 'a' <= char <= 'z':
                pass_id = char
                passengers.add(pass_id)
                pass_locs[pass_id] = (r, c)
            elif char == 'X':
                stations.append((r, c))
            elif char == '#':
                buildings.append((r, c))

    try:
        with open(output_file, 'w', encoding='utf-8') as f_out:
            
            # --- 1. PROGRAMA BASE (Hechos eternos) ---
            f_out.write("#program base.\n\n") 
            f_out.write(f"rows({n}).\n")
            f_out.write(f"cols({m}).\n\n")

            for t in sorted(list(taxis)):
                f_out.write(f"taxi({t}).\n")
            for p in sorted(list(passengers)):
                f_out.write(f"passenger({p}).\n")
            
            # Celdas y edificios
            for r in range(n):
                for c in range(m):
                    f_out.write(f"cell({r},{c}).\n")
            
            for r, c in buildings:
                f_out.write(f"building({r},{c}).\n")
                
            for r, c in stations:
                f_out.write(f"station({r},{c}).\n")

            # --- 2. PROGRAMA INICIAL (Estado t=0) ---
            f_out.write("\n#program initial.\n")
            
            f_out.write("% Taxi locations\n")
            for t in sorted(taxi_locs.keys()):
                r, c = taxi_locs[t]
                f_out.write(f"holds(at(taxi({t}),{r},{c}),0).\n")
            
            f_out.write("\n% Passenger locations\n")
            for p in sorted(pass_locs.keys()):
                r, c = pass_locs[p]
                f_out.write(f"holds(at(pass({p}),{r},{c}),0).\n")

    except IOError:
        print("Error writing output file.")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Use: python encode.py <input> <output>")
        sys.exit(1)
    convert_taxi_map_to_facts(sys.argv[1], sys.argv[2])