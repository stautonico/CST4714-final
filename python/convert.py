with open("payload.sql", "r") as f:
    data = f.read()

with open("payload.converted.sql", "w") as f2:
    lines = data.split("\n\n")

    for line in lines:
        f2.write(line.replace("\n", "").replace("        ", "") + "\n")