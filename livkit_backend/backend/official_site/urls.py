from django.urls import path

from . import views

urlpatterns = [
    path('',views.home, name='home'),
    path('about',views.about, name='about'),
    path('blogs',views.blogs, name='blogs'),
    path('subscription',views.subscription, name='subscription'),
    path('userprofile',views.userprofile, name='userprofile'),
    path('userprivacy',views.userprivacy, name='userprivacy'),
    path('pricing',views.pricing, name='pricing'),
    path('sign_in',views.sign_in, name='signin'),
    path('sign_up',views.sign_up, name='signup'),
    path('recover-password',views.recover_password, name='recover-password'),
    path('dashboard',views.dashboard, name='dashboard'),
    path('comingsoon',views.comingsoon, name='comingsoon'),
    
    path('logout', views.logout_view, name='logout'),
    
]