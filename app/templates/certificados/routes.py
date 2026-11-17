from flask import Blueprint, render_template, request, jsonify
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
import logging

from app.database import get_connection

certificados = Blueprint(
    "certificados",
    __name__,
    template_folder="."
)

@certificados.route("/validadorqr-sep")
def inicio():

    D3 = request.args.get("D3", "").strip()

    datos = {
        "rfc": "",
        "cadena_original": ""
    }

    # Validar parametro D3
    if not D3 or "_" not in D3:
        return render_template(
            "certificados/index.html",
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
            "certificados/index.html",
            datos=datos,
            encontrado=False
        ), 400

    db = get_connection()

    try:

        consulta = text("""
            SELECT RFC, SELLO
            FROM qr_certificados
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
                "certificados/index.html",
                datos=datos,
                encontrado=False
            ), 404

        datos = {
            "rfc": row["RFC"],
            "cadena_original": row["SELLO"]
        }

        return render_template(
            "certificados/index.html",
            datos=datos,
            encontrado=True
        )

    except SQLAlchemyError:

        logging.exception("Error consultando qr_certificados en MySQL")

        return render_template(
            "certificados/index.html",
            datos=datos,
            encontrado=False
        ), 500

    finally:
        db.close()

@certificados.route("/api/validacion/<sello>")
def obtener_validacion(sello):
    """
    Obtiene los datos de validación usando el sello como llave
    
    Args:
        sello: Sello único de la constancia
    
    Returns:
        JSON con datos de la validación o error 404
    """
    
    if not sello or sello.strip() == "":
        return jsonify({'error': 'Sello no válido'}), 400

    db = get_connection()

    try:
        consulta = text("""
            SELECT nombre_completo, curp, fecha_expedicion, vigencia, folio
            FROM qr_certificados
            WHERE SELLO = :sello
            LIMIT 1
        """)

        row = db.execute(
            consulta,
            {"sello": sello}
        ).mappings().first()

        if row is None:
            return jsonify({'error': 'Constancia no encontrada'}), 404

        return jsonify({
            'success': True,
            'sello': sello,
            'nombre_completo': row['NOMBRE_COMPLETO'],
            'curp': row['CURP'],
            'fecha_expedicion': row['FECHA_EXPEDICION'],
            'vigencia': row['VIGENCIA'],
            'folio': row['FOLIO']
        }), 200

    except SQLAlchemyError as e:
        logging.exception("Error consultando qr_certificados en MySQL")
        return jsonify({'error': 'Error al consultar la base de datos'}), 500

    finally:
        db.close()