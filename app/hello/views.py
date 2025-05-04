import os
import requests
from django.shortcuts import redirect, render
from django.conf import settings
from django.contrib.auth import logout as django_logout

def home(request):
    if not request.session.get("id_token"):
        return redirect("login")
    return render(request, "helloworld.html")

def login_view(request):
    domain = os.environ.get("COGNITO_DOMAIN")
    client_id = os.environ.get("COGNITO_CLIENT_ID")
    redirect_uri = f"http://{request.get_host()}/callback/"
    auth_url = f"{domain}/oauth2/authorize?response_type=code&client_id={client_id}&redirect_uri={redirect_uri}&scope=email+openid+profile"
    return redirect(auth_url)

def logout_view(request):
    django_logout(request)
    domain = os.environ.get("COGNITO_DOMAIN")
    client_id = os.environ.get("COGNITO_CLIENT_ID")
    logout_url = f"{domain}/logout?client_id={client_id}&logout_uri=http://{request.get_host()}/"
    return redirect(logout_url)

def cognito_callback(request):
    code = request.GET.get("code")
    if not code:
        return render(request, "helloworld.html", {"error": "Authorization code missing"})

    token_url = f"{settings.COGNITO_DOMAIN}/oauth2/token"
    redirect_uri = f"http://{request.get_host()}/callback/"

    data = {
        "grant_type": "authorization_code",
        "client_id": os.environ.get("COGNITO_CLIENT_ID"),
        "client_secret": os.environ.get("COGNITO_CLIENT_SECRET"),
        "code": code,
        "redirect_uri": redirect_uri
    }

    headers = {"Content-Type": "application/x-www-form-urlencoded"}
    response = requests.post(token_url, data=data, headers=headers)

    if response.status_code == 200:
        tokens = response.json()
        request.session["id_token"] = tokens["id_token"]
        return redirect("/")
    else:
        return render(request, "helloworld.html", {"error": "Token exchange failed"})

    
