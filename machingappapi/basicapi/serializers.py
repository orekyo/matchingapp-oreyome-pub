from django.db.models import Q
from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import Profile, Matching, DirectMessage


class UserSerializer(serializers.ModelSerializer):

    class Meta:
        model = get_user_model()
        fields = ('email', 'password', 'username', 'id')
        extra_kwargs = {'password': {'write_only': True, 'min_length': 8}}

    def create(self, validated_data):
        user = get_user_model().objects.create_user(**validated_data)
        return user

    def update(self, use_instance, validated_data):
        for attr, value in validated_data.items():
            if attr == 'password':
                use_instance.set_password(value)
            else:
                setattr(use_instance, attr, value)
        use_instance.save()
        return use_instance


class ProfileSerializer(serializers.ModelSerializer):

    created_at = serializers.DateTimeField(format='%Y-%m-%d %H:%M:%S', read_only=True)
    updated_at = serializers.DateTimeField(format='%Y-%m-%d %H:%M:%S', read_only=True)

    class Meta:
        model = Profile
        fields = (
            'user', 'is_special', 'is_kyc', 'top_image', 'nickname', 'created_at', 'updated_at',
            'age', 'sex', 'height', 'location', 'work', 'revenue', 'graduation',
            'hobby', 'passion', 'tweet', 'introduction',
            'send_favorite', 'receive_favorite', 'stock_favorite'
        )
        extra_kwargs = {'user': {'read_only': True}}


class MatchingSerializer(serializers.ModelSerializer):

    created_at = serializers.DateTimeField(format='%Y-%m-%d %H:%M:%S', read_only=True)

    class Meta:
        model = Matching
        fields = ('id', 'approaching', 'approached', 'approved', 'created_at')
        extra_kwargs = {'approaching': {'read_only': True}}


class MatchingFilter(serializers.PrimaryKeyRelatedField):

    def get_queryset(self):
        request = self.context['request']
        lovers = Matching.objects.filter(Q(approached=request.user) & Q(approved=True))

        list_lover = []
        for lover in lovers:
            list_lover.append(lover.approaching.id)

        queryset = get_user_model().objects.filter(id__in=list_lover)
        return queryset


class DirectMessageSerializer(serializers.ModelSerializer):

    created_at = serializers.DateTimeField(format='%Y-%m-%d %H:%M:%S', read_only=True)
    receiver = MatchingFilter()

    class Meta:
        model = DirectMessage
        fields = ('id', 'sender', 'receiver', 'message', 'created_at')
        extra_kwargs = {'sender': {'read_only': True}}
