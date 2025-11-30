from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
import mysql.connector
from passlib.hash import pbkdf2_sha256
from pydantic import BaseModel
import os
import uuid

app = FastAPI()

# -------- CORS --------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -------- BD --------
db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="",
    database="proyecto_evaluacion"
)
cursor = db.cursor(dictionary=True)

# Crear carpeta para fotos
if not os.path.exists("evidencias"):
    os.makedirs("evidencias")


# -------- MODELOS --------
class User(BaseModel):
    username: str
    password: str


class Paquete(BaseModel):
    codigo: str
    direccion_destino: str
    descripcion: str
    asignado_a: int


# -------- REGISTER --------
@app.post("/register")
def register(user: User):
    try:
        hashed = pbkdf2_sha256.hash(user.password)
        sql = "INSERT INTO usuarios (username, password_hash) VALUES (%s, %s)"
        cursor.execute(sql, (user.username, hashed))
        db.commit()

        return {"msg": "Usuario registrado correctamente"}

    except Exception as e:
        print("ERROR REGISTER:", e)
        raise HTTPException(status_code=500, detail=str(e))


# -------- LOGIN --------
@app.post("/login")
def login(user: User):
    sql = "SELECT * FROM usuarios WHERE username=%s"
    cursor.execute(sql, (user.username,))
    usr = cursor.fetchone()

    if not usr:
        raise HTTPException(status_code=401, detail="Credenciales incorrectas")

    if not pbkdf2_sha256.verify(user.password, usr["password_hash"]):
        raise HTTPException(status_code=401, detail="Credenciales incorrectas")

    return {"msg": "Login correcto", "usuario": usr}


# -------- CREAR PAQUETE --------
@app.post("/paquetes")
def crear_paquete(p: Paquete):
    sql = """INSERT INTO paquetes 
             (codigo, direccion_destino, descripcion, asignado_a)
             VALUES (%s, %s, %s, %s)"""
    cursor.execute(sql, (p.codigo, p.direccion_destino, p.descripcion, p.asignado_a))
    db.commit()

    return {"msg": "Paquete creado"}


# -------- OBTENER PAQUETES POR AGENTE --------
@app.get("/paquetes/{usuario_id}")
def paquetes_usuario(usuario_id: int):
    sql = "SELECT * FROM paquetes WHERE asignado_a=%s"
    cursor.execute(sql, (usuario_id,))
    return cursor.fetchall()


# -------- MARCAR ENTREGA CON FOTO Y GPS --------
@app.post("/entregar-paquete")
def entregar_paquete(
    paquete_id: int = Form(...),
    latitud: float = Form(...),
    longitud: float = Form(...),
    foto: UploadFile = File(...)
):
    try:
        # Guardar imagen
        extension = foto.filename.split(".")[-1]
        nombre_archivo = f"{uuid.uuid4()}.{extension}"
        ruta = f"evidencias/{nombre_archivo}"

        with open(ruta, "wb") as f:
            f.write(foto.file.read())

        # Guardar evidencia en BD
        sql = """INSERT INTO evidencias_entrega
                 (paquete_id, foto_ruta, latitud, longitud)
                 VALUES (%s, %s, %s, %s)"""
        cursor.execute(sql, (paquete_id, ruta, latitud, longitud))
        db.commit()

        return {"msg": "Entrega registrada correctamente", "foto": ruta}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
