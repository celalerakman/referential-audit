import unittest
from main import example_database,query

class Query(unittest.TestCase):
    def test_known_rows(self):
        db=example_database()
        try:
            result=query(db)
            self.assertEqual(result,[])
        finally: db.close()
