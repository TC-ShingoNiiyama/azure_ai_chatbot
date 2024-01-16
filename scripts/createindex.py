import requests
import json
import os
from os.path import join, dirname
from dotenv import load_dotenv
from azure.identity import DefaultAzureCredential
from azure.mgmt.storage import StorageManagementClient
from azure.mgmt.search import SearchManagementClient

load_dotenv(verbose=True)

dotenv_path = join(dirname(__file__), '../.azure/azure/.env')
load_dotenv(dotenv_path)

AZURE_OPENAI_ENDPOINT = os.environ.get("AZURE_OPENAI_ENDPOINT")
AZURE_OPENAI_EMB_DEPLOYMENT = os.environ.get("AZURE_OPENAI_EMB_DEPLOYMENT")
AZURE_OPENAI_EMB_API_KEY = os.environ.get("AZURE_OPENAI_EMB_API_KEY")
AZURE_OPENAI_EMB_ENDPOINT = os.environ.get("AZURE_OPENAI_EMB_ENDPOINT")
AZURE_OPENAI_API_KEY = os.environ.get("AZURE_OPENAI_API_KEY")
#AZURE_SEARCH_API_KEY = os.environ.get("AZURE_SEARCH_API_KEY")
AZURE_SEARCH_ENDPOINT = os.environ.get("AZURE_SEARCH_ENDPOINT")
AZURE_SEARCH_DATASOURCE = os.environ.get("AZURE_SEARCH_DATASOURCE")
AZURE_SEARCH_SKILLSET = os.environ.get("AZURE_SEARCH_SKILLSET")
AZURE_SEARCH_SERVICE = os.environ.get("AZURE_SEARCH_SERVICE")
AZURE_SEARCH_INDEX = os.environ.get("AZURE_SEARCH_INDEX")
AZURE_SEARCH_INDEXER = os.environ.get("AZURE_SEARCH_INDEXER")
AZURE_STORAGE_ACCOUNT = os.environ.get("AZURE_STORAGE_ACCOUNT")
AZURE_SUBSCRIPTION_ID = os.environ.get("AZURE_SUBSCRIPTION_ID")
AZURE_STORAGE_RESOURCE_GROUP = os.environ.get("AZURE_STORAGE_RESOURCE_GROUP")
AZURE_SEARCH_API_VERSION = os.environ.get("AZURE_SEARCH_API_VERSION")

client = SearchManagementClient(
    credential=DefaultAzureCredential(),
    subscription_id=AZURE_SUBSCRIPTION_ID,
)

response = client.admin_keys.get(
    resource_group_name=AZURE_STORAGE_RESOURCE_GROUP,
    search_service_name=AZURE_SEARCH_SERVICE,
)
search_key = response.primary_key

headers = { "api-key " : search_key, "Content-Type" : "application/json" }

client = StorageManagementClient(
    credential=DefaultAzureCredential(),
    subscription_id=AZURE_SUBSCRIPTION_ID,
)


response = client.storage_accounts.list_keys(
    resource_group_name=AZURE_STORAGE_RESOURCE_GROUP,
    account_name=AZURE_STORAGE_ACCOUNT,
)

account_key = response.keys[0].value

connection_string = "ResourceId=/subscriptions/" + AZURE_SUBSCRIPTION_ID + "/resourceGroups/" + AZURE_STORAGE_RESOURCE_GROUP + "/providers/Microsoft.Storage/storageAccounts/" + AZURE_STORAGE_ACCOUNT + ";"
print(connection_string)
request_body = {
  "description" : "データソース",
  "type" : "azureblob",
  "credentials" :
  { "connectionString" :
    connection_string
  },
  "container" : { "name" : "content" }
}
string = f"{AZURE_SEARCH_ENDPOINT}datasources/{AZURE_SEARCH_DATASOURCE}?api-version={AZURE_SEARCH_API_VERSION}"

ret = requests.put(string, headers=headers, data=json.dumps(request_body))
print(ret)

request_body = {
  "description": "スキルセット",
  "skills": [
    {
      "@odata.type": "#Microsoft.Skills.Util.DocumentExtractionSkill",
      "name": "#1",
      "context": "/document",
      "parsingMode": "default",
      "dataToExtract": "contentAndMetadata",
      "inputs": [
        {
          "name": "file_data",
          "source": "/document/file_data"
        }
      ],
      "outputs": [
        {
          "name": "content",
          "targetName": "extractedcontent"
        },
        {
          "name": "normalized_images",
          "targetName": "extracted_normalized_images"
        }
      ],
      "configuration": {
        "imageAction": "none"
      }
    },
    {
      "@odata.type": "#Microsoft.Skills.Text.AzureOpenAIEmbeddingSkill",
      "name": "#2",
      "description": "Connects a deployed embedding model.",
      "context": "/document",
      "resourceUri": AZURE_OPENAI_EMB_ENDPOINT,
      "apiKey": AZURE_OPENAI_EMB_API_KEY,
      "deploymentId": AZURE_OPENAI_EMB_DEPLOYMENT,
      "inputs": [
        {
          "name": "text",
          "source": "/document/content"
        }
      ],
      "outputs": [
        {
          "name": "embedding",
          "targetName": "embedding"
        }
      ],
    }
  ],
  "cognitiveServices": {
    "@odata.type": "#Microsoft.Azure.Search.DefaultCognitiveServices",
  }
}
string = f"{AZURE_SEARCH_ENDPOINT}/skillsets/{AZURE_SEARCH_SKILLSET}?api-version={AZURE_SEARCH_API_VERSION}"
ret = requests.put(string, headers=headers, data=json.dumps(request_body))
print(ret.status_code)

request_body = {
    "fields": [
      {
        "name": "id",
        "type": "Edm.String",
        "searchable": False,
        "filterable": False,
        "retrievable": True,
        "sortable": False,
        "facetable": False,
        "key": True,
        "synonymMaps": []
      },
      {
        "name": "content",
        "type": "Edm.String",
        "searchable": True,
        "filterable": False,
        "retrievable": True,
        "sortable": False,
        "facetable": False,
        "key": False,
        "analyzer": "ja.microsoft",
        "synonymMaps": []
      },
      {
        "name": "embedding",
        "type": "Collection(Edm.Single)",
        "searchable": True,
        "filterable": False,
        "retrievable": True,
        "sortable": False,
        "facetable": False,
        "key": False,
        "dimensions": 1536,
        "vectorSearchProfile": "default-profile",
        "synonymMaps": []
      },
      {
        "name": "category",
        "type": "Edm.String",
        "searchable": False,
        "filterable": True,
        "retrievable": False,
        "sortable": False,
        "facetable": True,
        "key": False,
        "synonymMaps": []
      },
      {
        "name": "sourcepage",
        "type": "Edm.String",
        "searchable": False,
        "filterable": True,
        "retrievable": True,
        "sortable": False,
        "facetable": True,
        "key": False,
        "synonymMaps": []
      },
      {
        "name": "sourcefile",
        "type": "Edm.String",
        "searchable": False,
        "filterable": True,
        "retrievable": True,
        "sortable": False,
        "facetable": True,
        "key": False,
        "synonymMaps": []
      }
    ],
    "scoringProfiles": [],
    "suggesters": [],
    "analyzers": [],
    "normalizers": [],
    "tokenizers": [],
    "tokenFilters": [],
    "charFilters": [],
    "similarity": {
      "@odata.type": "#Microsoft.Azure.Search.BM25Similarity",
    },
    "semantic": {
      "configurations": [
        {
          "name": "default",
          "prioritizedFields": {
            "prioritizedContentFields": [
              {
                "fieldName": "content"
              }
            ],
            "prioritizedKeywordsFields": []
          }
        }
      ]
    },
    "vectorSearch": {
      "algorithms": [
        {
          "name": "default",
          "kind": "hnsw",
          "hnswParameters": {
            "metric": "cosine",
            "m": 4,
            "efConstruction": 400,
            "efSearch": 800
          },
        },
        {
          "name": "custom_vector",
          "kind": "hnsw",
          "hnswParameters": {
            "metric": "cosine",
            "m": 4,
            "efConstruction": 800,
            "efSearch": 800
          },
        }
      ],
      "profiles": [
        {
          "name": "default-profile",
          "algorithm": "default",
          "vectorizer": "vectorizer4"
        }
      ],
      "vectorizers": [
        {
          "name": "vectorizer4",
          "kind": "azureOpenAI",
          "azureOpenAIParameters": {
            "resourceUri": AZURE_OPENAI_EMB_ENDPOINT,
            "deploymentId": AZURE_OPENAI_EMB_DEPLOYMENT,
            "apiKey": AZURE_OPENAI_EMB_API_KEY,
          },
        }
      ]
    }
}

ret = requests.put(f"{AZURE_SEARCH_ENDPOINT}/indexes/{AZURE_SEARCH_INDEX}?api-version={AZURE_SEARCH_API_VERSION}", headers=headers, data=json.dumps(request_body))
print(ret.status_code)

request_body = {
  "description": "インデクサ",
  "dataSourceName": AZURE_SEARCH_DATASOURCE,
  "skillsetName": AZURE_SEARCH_SKILLSET,
  "targetIndexName": AZURE_SEARCH_INDEX,
  "parameters": {
    "configuration": {
      "indexedFileNameExtensions": "pdf,docx,md,xlsx,xls,doc",
      "allowSkillsetToReadFileData": True,
      "parsingMode": "default"
    }
  },
  "fieldMappings": [
    {
      "sourceFieldName": "metadata_storage_name",
      "targetFieldName": "sourcefile",
    },
    {
      "sourceFieldName": "metadata_storage_name",
      "targetFieldName": "sourcepage",
    }
  ],
  "outputFieldMappings": [
    {
      "sourceFieldName": "/document/embedding",
      "targetFieldName": "embedding"
    }
  ],
}
string = f"{AZURE_SEARCH_ENDPOINT}/indexers/{AZURE_SEARCH_INDEXER}?api-version={AZURE_SEARCH_API_VERSION}"
ret = requests.put(string, headers=headers, data=json.dumps(request_body))
print(ret.status_code)