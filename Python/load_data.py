import os
import pandas as pd
from sqlalchemy import create_engine
from urllib.parse import quote_plus

# -----------------------------
# MySQL Connection
# -----------------------------
username = "root"
password = quote_plus("Mysql@1999")   # Replace with your password
host = "127.0.0.1"
port = "3306"
database = "primenestdb"

engine = create_engine(
    f"mysql+pymysql://{username}:{password}@{host}:{port}/{database}"
)

# -----------------------------
# Project Path
# -----------------------------
current_dir = os.path.dirname(os.path.abspath(__file__))
project_root = os.path.dirname(current_dir)

base_path = os.path.join(project_root, "Data", "CSV Files")


# -----------------------------
# File Mapping
# -----------------------------
files={
    "DimLocation.csv":"DimLocation",
    "DimDate.csv":"DimDate",
    "DimCustomer.csv":"DimCustomer",
    "DimAgent.csv":"DimAgent",
    "DimProperty.csv":"DimProperty",
    "FactPropertyTransactions.csv":"FactPropertyTransactions"
}

#================================
# Load Data
# ===============================
for csv_file, table_name in files.items():

    file_path = os.path.join(base_path, csv_file)

    print(f"Loading {table_name}...")

    df = pd.read_csv(file_path)

    df.to_sql(
        table_name,
        con=engine,
        if_exists="append",
        index=False
    )

    print(f"✅ {len(df)} rows inserted into {table_name}")

print("\n🎉 All tables loaded successfully!")
