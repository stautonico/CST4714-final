import os
import subprocess

# Go through all of the SQL files in the SQL folder and make sure that
# file's text exists in at least one md file


files_to_check = []
files_to_check_against = []

couldnt_find = []


def find_file(file):
    global files_to_check
    with open(file, "r") as f:
        data = f.read()

    bigstring = data.replace("\n", "").replace(" ", "").replace("\t", "")

    for check_against in files_to_check_against:
        with open(check_against, "r") as f:
            source = f.read()

        sourcebigstring = source.replace("\n", "").replace(" ", "").replace("\t", "")

        if bigstring in sourcebigstring:
            return

    couldnt_find.append(file)


for subdir, dirs, files in os.walk("../SQL"):
    for file in files:
        files_to_check.append(os.path.join(subdir, file))

for subdir, dirs, files in os.walk("../docs/Writerside/topics"):
    for file in files:
        files_to_check_against.append(os.path.join(subdir, file))

for file in files_to_check:
    find_file(file)

print("These are the files we couldn't validate")
print(", ".join(couldnt_find))
