import os
from os.path import join, dirname
from dotenv import load_dotenv
import requests

dotenv_path = join(dirname(__file__), '../.azure/azure/.env')
load_dotenv(dotenv_path)

AZURE_SEARCH_API_KEY = os.environ.get("AZURE_SEARCH_API_KEY")
AZURE_SEARCH_ENDPOINT = os.environ.get("AZURE_SEARCH_ENDPOINT")
AZURE_SEARCH_API_VERSION = os.environ.get("AZURE_SEARCH_API_VERSION")

headers = { "api-key " : AZURE_SEARCH_API_KEY, "Content-Type" : "application/json" }

def delete_resource(resource, resource_name):
    ret = requests.delete(f"{AZURE_SEARCH_ENDPOINT}/{resource}/{resource_name}?api-version={AZURE_SEARCH_API_VERSION}", headers=headers)
    print(ret.status_code)

delete_resource('indexes', os.environ.get("AZURE_SEARCH_INDEX"))
delete_resource('indexers', os.environ.get("AZURE_SEARCH_INDEXER"))
delete_resource('skillsets', os.environ.get("AZURE_SEARCH_SKILLSET"))
delete_resource('datasources', os.environ.get("AZURE_SEARCH_DATASOURCE"))