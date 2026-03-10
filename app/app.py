from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello():
    return {"message": "Hello from CI/CD pipeline. Updated by a pipeline triggered by git push"}

if __name__   == "__main__":
    app.run(host="0.0.0.0", port=5000)
