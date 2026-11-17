from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import os

engine = None
SessionLocal = None


def init_database(config):

    global engine, SessionLocal

    connect_args = {}
    
    if config.DB_CA_CERT and os.path.exists(config.DB_CA_CERT):
        connect_args["ssl_ca"] = config.DB_CA_CERT
        connect_args["ssl_verify_cert"] = True
        connect_args["ssl_verify_identity"] = True

    engine = create_engine(
        config.SQLALCHEMY_DATABASE_URI,
        pool_pre_ping=True,
        pool_size=3,
        max_overflow=2,
        pool_timeout=30,
        pool_recycle=1800,
        connect_args=connect_args
    )

    SessionLocal = sessionmaker(
        bind=engine,
        autoflush=False,
        autocommit=False
    )


def get_connection():

    if SessionLocal is None:
        raise RuntimeError(
            "La conexión a MySQL no está inicializada"
        )

    return SessionLocal()