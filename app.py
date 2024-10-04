from flask import Flask, request, jsonify
import os
from langchain.chat_models import ChatOpenAI
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.prompts import ChatPromptTemplate
from langchain.chains import LLMChain

app = Flask(__name__)

# Set your Google GenAI API key here
os.environ["GOOGLE_API_KEY"] = "AIzaSyCXxpGfK5AQxOWRcfTaKCb7KCHhG6AxojA"

# Initialize the Chat Model from LangChain
chat = ChatGoogleGenerativeAI(model="gemini-1.5-flash", temperature=0.9)

# Create a prompt template
joke_prompt = ChatPromptTemplate.from_template(
    "Based on the following question, create a funny joke:\n\nQuestion: {question}\nJoke:"
)

@app.route('/ask', methods=['POST'])
def ask():
    data = request.get_json()
    question = data.get('question')
    
    # Create a chain that combines the prompt with the model
    chain = LLMChain(llm=chat, prompt=joke_prompt)
    
    # Get a response from the model
    response = chain({"question": question})
    
    return jsonify({'response': response['text']})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
