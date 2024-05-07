# IMPORTANT NOTES

Most of the data generated and inserted into the database using python.
This data could come from another source such as a CSV file or another database, but in this case, it was randomly
generated using a python module called `Mimesis`.

All of this code is available on my [GitHub](https://github.com/stautonico/CST4714-final)

To run this code:

1. `cd python`
2. `pip install -r requirements.txt` (install dependencies)
3. `python3 reset_database.py` (drop the tables (if applicable) and re-create them (in the correct order))
4. `python3 generate_final_test_data.py` (this generates some fake data, inserts it into the database, then outputs a
   file called `payload.sql` will all the insert statements)


All the other files in the `python` folder were for development, and can be ignored 