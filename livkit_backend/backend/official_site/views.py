from django.shortcuts import render, redirect
from django.http import HttpResponse
from accounts import backends
from .auth import jwt_required
import requests
from django.conf import settings

API_BASE = "http://127.0.0.1:8000/api/auth"



def sign_in(request):
    if request.method == "POST":
        payload = {
            "email": request.POST.get("email"),
            "password": request.POST.get("password"),
        }

        r = requests.post(
            "http://127.0.0.1:8000/api/auth/login/",
            json=payload
        )

        if r.status_code != 200:
            return render(request, "sign-in.html", {
                "error": "Invalid credentials"
            })

        tokens = r.json()
        response = redirect("dashboard")

        response.set_cookie(
            "access",
            tokens["access"],
            httponly=True,
            samesite="Lax",
        )
        response.set_cookie(
            "refresh",
            tokens["refresh"],
            httponly=True,
            samesite="Lax",
        )

        return response

    return render(request, "sign-in.html")

def sign_up(request):
    if request.method == "POST":
        username = request.POST.get("username")
        email = request.POST.get("email")
        password = request.POST.get("password")
        confirm = request.POST.get("password_confirm")

        if password != confirm:
            return render(request, "sign-up.html", {
                "error": "Passwords do not match"
            })

        payload = {
            "username": username,
            "email": email,
            "password": password,
        }


        r = requests.post(f"{API_BASE}/register/", json=payload)

        if r.status_code == 201:
            return redirect("signin")

        return render(request, "sign-up.html", {
            "error": r.json()
        })

    

    return render(request, "sign-up.html")

@jwt_required
def pricing(request):
    return render(request, 'pricing.html', {
        "user": request.user
        
    })

@jwt_required
def dashboard(request):
    return render(request, "index.html", {
        "user": request.user
        
    })

def logout_view(request):
    response = redirect("home")
    response.delete_cookie("access")
    response.delete_cookie("refresh")
    return response

# Create your views here.
#navigation tabs start
def home(request):
    return render(request, 'home.html')

def about(request):
    return render(request, 'about-us.html')

def blogs(request):
    return render(request, 'blog-listing.html')

@jwt_required
def userprofile(request):
    return render(request, 'form-wizard.html', {
        "user": request.user
        
    })

def subscription(request):
    return render(request, 'pricing-plan.html')

@jwt_required
def userprivacy(request):
    return render(request, 'user-privacy-setting.html', {
        "user": request.user
        
    })


def comingsoon(request):
    return render(request, 'coming-soon.html')


def recover_password(request):
    return render(request, 'recoverpw.html')





