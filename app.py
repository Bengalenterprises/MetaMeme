from flask import Flask, request, jsonify, render_template
import openai
import os

app = Flask(__name__)

# Set your OpenAI API key here
openai.api_key = os.getenv("OPENAI_API_KEY")

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/generate-meme", methods=["POST"])
def generate_meme():
    data = request.json
    text = data.get("text")

    if not text:
        return jsonify({"error": "Text input is required"}), 400

    try:
        # Generate meme text using GPT-4
        response = openai.Completion.create(
            engine="text-davinci-003",  # Use GPT-4 when available
            prompt=f"Create a funny meme caption for: {text}",
            max_tokens=50,
            n=1,
            stop=None,
            temperature=0.7,
        )
        meme_text = response.choices[0].text.strip()

        # Generate meme image using DALL·E
        image_response = openai.Image.create(
            prompt=f"A funny meme about: {meme_text}",
            n=1,
            size="512x512"
        )
        meme_image_url = image_response.data[0].url

        return jsonify({"text": meme_text, "image_url": meme_image_url})

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(debug=True)
