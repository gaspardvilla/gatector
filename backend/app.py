import uuid
from pathlib import Path
from fastapi import FastAPI, File, UploadFile, Form

app = FastAPI()
UPLOAD_DIR = Path(__file__).resolve().parent / "data"
UPLOAD_DIR.mkdir(exist_ok = True)


@app.get("/health")
async def health():
    return {"status": "ok"}



@app.post("/process")
async def process(file: UploadFile = File(...),
                  modality: str | None = Form(None),
                  device: str | None = Form(None)):
    # Exatract the request ID and create the run directory
    request_id = str(uuid.uuid4())
    run_dir = UPLOAD_DIR / request_id
    run_dir.mkdir(parents = True, exist_ok = True)

    # Save the file to the run directory
    saved_path = run_dir / file.filename
    with open(saved_path, "wb") as f:
        content = await file.read()
        f.write(content)

    # Run the response
    return {"ok": True,
            "requestId": request_id,
            "savedPath": str(saved_path),}
