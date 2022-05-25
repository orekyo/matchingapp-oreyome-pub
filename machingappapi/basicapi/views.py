from django.http import HttpResponse
from rest_framework.exceptions import ValidationError
from rest_framework.generics import CreateAPIView, RetrieveUpdateAPIView
from rest_framework.viewsets import ModelViewSet, ReadOnlyModelViewSet
from rest_framework.permissions import AllowAny
from rest_framework import status
from .models import User, Profile, Matching, DirectMessage
from .serializers import UserSerializer, ProfileSerializer, MatchingSerializer, DirectMessageSerializer
from django.db.models import Q

from rest_framework.response import Response
from .models import UserActivateTokens
from rest_framework.decorators import api_view, permission_classes
from datetime import datetime
from django.shortcuts import redirect
from django.conf import settings
import stripe

stripe.api_key = settings.STRIPE_API_SECRET_KEY


class CreateUserView(CreateAPIView):
    serializer_class = UserSerializer
    permission_classes = (AllowAny,)


class UserView(RetrieveUpdateAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def get_queryset(self):
        return self.queryset.filter(id=self.request.user.id)


@api_view(['GET'])
@permission_classes([AllowAny])
def pay_stripe(request, token_id):
    try:
        tokens = UserActivateTokens.objects.all().filter(
            token_id=token_id,
            expired_at__gte=datetime.now()
        ).first()
        if tokens is None:
            return Response({'message': 'トークン間違いもしくはトークンの有効期限切れです'})
        checkout_session = stripe.checkout.Session.create(
            line_items=[
                {
                    'price': settings.STRIPE_ITEM_PRICE,
                    'quantity': 1,
                },
            ],
            mode='payment',
            success_url=f'{settings.MY_URL}/api/users/{tokens.activate_token}/activation/',
            cancel_url=f'{settings.MY_URL}/api/users/payment/cancel/',
        )
    except Exception as e:
        return str(e)
    return redirect(checkout_session.url, code=303)


@api_view(['GET'])
@permission_classes([AllowAny])
def pay_stripe_cancel(request):
    return HttpResponse('決済がキャンセルされました')


@api_view(['GET'])
@permission_classes([AllowAny])
def activate_user(request, activate_token):
    activated_user = UserActivateTokens.objects.activate_user_by_token(activate_token)
    if hasattr(activated_user, 'is_active'):
        if activated_user.is_active:
            message = 'ユーザーのアクティベーションが完了しました'
        if not activated_user.is_active:
            message = 'アクティベーションが失敗しています。管理者に問い合わせてください'
    if not hasattr(activated_user, 'is_active'):
        message = 'エラーが発生しました'
    return HttpResponse(message)


class ProfileViewSet(ModelViewSet):
    queryset = Profile.objects.all()
    serializer_class = ProfileSerializer

    def get_queryset(self):
        if hasattr(self.request.user, 'profile'):
            sex = self.request.user.profile.sex
            # Profile.SEX[0][0] = 'male', Profile.SEX[1][0] = 'female'
            if sex == Profile.SEX[0][0]:
                reversed_sex = Profile.SEX[1][0]
            if sex == Profile.SEX[1][0]:
                reversed_sex = Profile.SEX[0][0]
            return self.queryset.filter(sex=reversed_sex)
        return self.queryset.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    def destroy(self, request, *args, **kwargs):
        response = {'message': 'Delete is not allowed !'}
        return Response(response, status=status.HTTP_400_BAD_REQUEST)

    def update(self, request, *args, **kwargs):
        response = {'message': 'Update DM is not allowed'}
        return Response(response, status=status.HTTP_400_BAD_REQUEST)

    def partial_update(self, request, *args, **kwargs):
        response = {'message': 'Patch DM is not allowed'}
        return Response(response, status=status.HTTP_400_BAD_REQUEST)


class MyProfileListView(RetrieveUpdateAPIView):
    queryset = Profile.objects.all()
    serializer_class = ProfileSerializer

    def get_queryset(self):
        return self.queryset.filter(user=self.request.user)


class MatchingViewSet(ModelViewSet):
    queryset = Matching.objects.all()
    serializer_class = MatchingSerializer

    def get_queryset(self):
        return self.queryset.filter(Q(approaching=self.request.user) | Q(approached=self.request.user))

    def perform_create(self, serializer):
        try:
            serializer.save(approaching=self.request.user)
        except ValidationError:
            raise ValidationError("User cannot approach unique user a number of times")

    def destroy(self, request, *args, **kwargs):
        response = {'message': 'Delete is not allowed !'}
        return Response(response, status=status.HTTP_400_BAD_REQUEST)


class DirectMessageViewSet(ModelViewSet):
    queryset = DirectMessage.objects.all()
    serializer_class = DirectMessageSerializer

    def get_queryset(self):
        return self.queryset.filter(sender=self.request.user)

    def perform_create(self, serializer):
        serializer.save(sender=self.request.user)

    def destroy(self, request, *args, **kwargs):
        response = {'message': 'Delete DM is not allowed'}
        return Response(response, status=status.HTTP_400_BAD_REQUEST)


class InboxListView(ReadOnlyModelViewSet):
    queryset = DirectMessage.objects.all()
    serializer_class = DirectMessageSerializer

    def get_queryset(self):
        return self.queryset.filter(receiver=self.request.user)
