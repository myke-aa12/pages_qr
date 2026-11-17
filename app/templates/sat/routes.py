from flask import Blueprint, render_template, request
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
import logging

from app.database import get_connection

sat = Blueprint("sat", __name__, template_folder=".")

@sat.route("/app/qr/faces/pages/mobile/validadorqr.html")
def inicio():

    D3 = request.args.get("D3", "").strip()

    datos = {
        "rfc": "",
        "cadena_original": ""
    }

    # Validar parametro D3
    if not D3 or "_" not in D3:
        return render_template(
            "sat/index.html",
            datos=datos,
            encontrado=False
        ), 400

    # Separar ID y RFC
    try:
        id_str, rfc = D3.split("_", 1)

        id_num = int(id_str)
        rfc = rfc.strip().upper()

        if id_num <= 0 or not rfc:
            raise ValueError

    except ValueError:
        return render_template(
            "sat/index.html",
            datos=datos,
            encontrado=False
        ), 400

    db = get_connection()

    try:

        consulta = text("""
            SELECT RFC, SELLO
            FROM qrsat
            WHERE ID = :id
            AND RFC = :rfc
            LIMIT 1
        """)

        row = db.execute(
            consulta,
            {
                "id": id_num,
                "rfc": rfc
            }
        ).mappings().first()

        if row is None:
            return render_template(
                "sat/index.html",
                datos=datos,
                encontrado=False
            ), 404

        datos = {
            "rfc": row["RFC"],
            "cadena_original": row["SELLO"]
        }

        return render_template(
            "sat/index.html",
            datos=datos,
            encontrado=True
        )

    except SQLAlchemyError:

        logging.exception("Error consultando qrsat en MySQL")

        return render_template(
            "sat/index.html",
            datos=datos,
            encontrado=False
        ), 500

    finally:
        db.close()