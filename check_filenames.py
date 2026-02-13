import os

path = r"c:\Users\Petr\Documents\Obsidian\Technomage\03_Концепты"

try:
    files = os.listdir(path)
    print(f"Total files: {len(files)}")
    
    target_names = ["Синхронистичность", "Эгрегор", "Энтропия"]
    
    found = []
    
    for f in files:
        name_lower = f.lower()
        # Check for target names
        for target in target_names:
            if target.lower() in name_lower:
                print(f"\nFound match for '{target}':")
                print(f"  Filename: {f}")
                print(f"  Repr: {repr(f)}")
                
                # Analyze characters for mixed scripts (Latin vs Cyrillic)
                chars = []
                for char in f:
                    cat = "UNKNOWN"
                    if '\u0041' <= char <= '\u005A' or '\u0061' <= char <= '\u007A':
                        cat = "LATIN"
                    elif '\u0400' <= char <= '\u04FF':
                        cat = "CYRILLIC"
                    else:
                        cat = "OTHER"
                    chars.append(f"{char}({cat})")
                print(f"  Char analysis: {' '.join(chars)}")
                found.append(target)

except Exception as e:
    print(f"Error: {e}")
