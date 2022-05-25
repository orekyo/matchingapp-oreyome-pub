from django.contrib import admin
from .models import User, UserActivateTokens, Profile, Matching, DirectMessage
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin


class ProfileInline(admin.StackedInline):
    model = Profile
    can_delete = False


class UserAdmin(BaseUserAdmin):
    ordering = ('id',)
    list_display = ('email', 'id', 'is_active', 'password')
    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        ('Personal Information', {'fields': ('username',)}),
        (
            'Permissions',
            {
                'fields': (
                    'is_active',
                    'is_staff',
                    'is_superuser',
                )
            }
        ),
        ('Important dates', {'fields': ('last_login',)}),
    )
    add_fieldsets = (
        (None, {
           'classes': ('wide',),
           'fields': ('email', 'password1', 'password2'),
        }),
    )
    inlines = (ProfileInline,)


class UserActivateTokensAdmin(admin.ModelAdmin):
    list_display = ('token_id', 'user', 'activate_token', 'expired_at')


class ProfileAdmin(admin.ModelAdmin):
    ordering = ('-created_at',)
    list_display = ('__str__', 'user', 'age', 'sex', 'tweet', 'from_last_login', 'created_at')


class MatchingAdmin(admin.ModelAdmin):
    ordering = ('-created_at',)
    list_display = ('id', '__str__', 'approved', 'created_at')


class DirectMessageAdmin(admin.ModelAdmin):
    ordering = ('-created_at',)
    list_display = ('id', '__str__', 'message', 'created_at')


admin.site.register(User, UserAdmin)
admin.site.register(UserActivateTokens, UserActivateTokensAdmin)
admin.site.register(Profile, ProfileAdmin)
admin.site.register(Matching, MatchingAdmin)
admin.site.register(DirectMessage, DirectMessageAdmin)

