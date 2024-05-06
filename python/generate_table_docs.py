#!/usr/bin/env python3

import os

output = ""

BASE_PATH = '/home/steve/Documents/GitHub/CST4714-final/SQL/CreateTables'

for file in os.listdir(BASE_PATH):
    with open(os.path.join(BASE_PATH, file), "r") as f:
        content = f.read()

        output += f"### {file.replace('.sql', '')}\n"
        output += f"<code-block lang=\"sql\">\n"
        output += content
        output += "\n</code-block>\n\n"


print(output)
