from rest_framework.routers import DefaultRouter
from django.urls import path
from django.conf.urls import include
from .views import CreateUserView
from .views import UserView
from .views import ProfileViewSet
from .views import MyProfileListView
from .views import MatchingViewSet
from .views import DirectMessageViewSet
from .views import InboxListView
from .views import activate_user
from .views import pay_stripe
from .views import pay_stripe_cancel

app_name = 'basicapi'

router = DefaultRouter()
router.register('profiles', ProfileViewSet)
router.register('favorite', MatchingViewSet)
router.register('dm-message', DirectMessageViewSet)
router.register('dm-inbox', InboxListView)

urlpatterns = [
    path('users/create/', CreateUserView.as_view(), name='users-create'),
    path('users/<uuid:token_id>/payment/', pay_stripe, name='pay-stripe'),
    path('users/payment/cancel/', pay_stripe_cancel, name='pay-stripe-cancel'),
    path('users/<uuid:activate_token>/activation/', activate_user, name='users-activation'),
    path('users/<uuid:pk>/', UserView.as_view(), name='users'),
    path('users/profile/<uuid:pk>/', MyProfileListView.as_view(), name='users-profile'),
    path('', include(router.urls)),
]
