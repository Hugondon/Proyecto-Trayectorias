from flask import Flask, redirect, url_for, jsonify, render_template, request
import json

app = Flask(__name__)

@app.route("/")
def home():
    return render_template("dataset.html")

@app.route("/admin", methods=["POST", "GET"])
def admin():
    if request.method == "POST":
        user = request.form["dat"]
        #return render_template("dataset.html")
        return redirect(url_for("user", usr = user))
    else:
        return render_template("admin.html")

@app.route("/<usr>")
def user(usr):
    return f"<h1>{usr}</h1>"

if __name__ == "__main__":
    app.run(host = "0.0.0.0", port = 5000)

