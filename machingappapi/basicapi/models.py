from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.conf import settings
import uuid
from datetime import datetime, timedelta
from django.core.validators import MinValueValidator, MaxValueValidator
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.core.mail import send_mail


class UserManager(BaseUserManager):

    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('Users must have an email address')

        user = self.model(email=self.normalize_email(email), **extra_fields)
        user.set_password(password)
        user.save(using=self._db)

        return user

    def create_superuser(self, email, password):
        user = self.create_user(email, password)
        user.is_active = True
        user.is_staff = True
        user.is_superuser = True
        user.save(using=self._db)

        return user


class User(AbstractBaseUser, PermissionsMixin):

    id = models.UUIDField(default=uuid.uuid4, primary_key=True, editable=False)
    email = models.EmailField(max_length=255, unique=True)
    username = models.CharField(max_length=255, blank=True)
    is_active = models.BooleanField(default=False)
    is_staff = models.BooleanField(default=False)

    objects = UserManager()

    USERNAME_FIELD = 'email'

    def __str__(self):
        return self.email


class UserActivateTokensManager(models.Manager):

    def activate_user_by_token(self, activate_token):
        user_activate_token = self.filter(
            activate_token=activate_token,
            expired_at__gte=datetime.now()
        ).first()
        if hasattr(user_activate_token, 'user'):
            user = user_activate_token.user
            user.is_active = True
            user.save()
            return user


class UserActivateTokens(models.Model):

    token_id = models.UUIDField(default=uuid.uuid4, primary_key=True, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    activate_token = models.UUIDField(default=uuid.uuid4)
    expired_at = models.DateTimeField()

    objects = UserActivateTokensManager()


@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def publish_activate_token(sender, instance, **kwargs):
    if not instance.is_active:
        user_activate_token = UserActivateTokens.objects.create(
            user=instance,
            expired_at=datetime.now()+timedelta(days=settings.ACTIVATION_EXPIRED_DAYS),
        )
        subject = 'Please Activate Your Account'
        message = f'URL?????????????????????????????????????????????????????????\n {settings.MY_URL}/api/users/{user_activate_token.token_id}/payment/'
    if instance.is_active:
        subject = 'Activated! Your Account!'
        message = '??????????????????????????????????????????????????????'
    from_email = settings.DEFAULT_FROM_EMAIL
    recipient_list = [
        instance.email,
    ]
    send_mail(subject, message, from_email, recipient_list)


def top_image_upload_path(instance, filename):
    ext = filename.split('.')[-1]
    return '/'.join(['images', 'top_image', f'{instance.user.id}{instance.nickname}.{ext}'])


class Profile(models.Model):

    user = models.OneToOneField(
        settings.AUTH_USER_MODEL, primary_key=True, on_delete=models.CASCADE, related_name='profile')

    """ Profile Fields """
    is_special = models.BooleanField(verbose_name="????????????", default=False)
    is_kyc = models.BooleanField(verbose_name="????????????", default=False)
    top_image = models.ImageField(
        verbose_name="???????????????", upload_to=top_image_upload_path, blank=True, null=True)
    nickname = models.CharField(verbose_name="??????????????????", max_length=20)
    created_at = models.DateTimeField(verbose_name="????????????", auto_now_add=True)
    updated_at = models.DateTimeField(verbose_name="????????????", auto_now=True, blank=True, null=True)

    """ Physical """
    age = models.PositiveSmallIntegerField(
        verbose_name="??????", validators=[MinValueValidator(18, '18?????????????????????????????????'),
                                       MaxValueValidator(100, '100???????????????????????????????????????')])
    SEX = [
        ('male', '??????'),
        ('female', '??????'),
    ]
    sex = models.CharField("??????", max_length=16, choices=SEX)
    height = models.PositiveSmallIntegerField(
        verbose_name="??????", blank=True, null=True,
        validators=[MinValueValidator(140, '140cm?????????????????????????????????'),
                    MaxValueValidator(200, '200cm?????????????????????????????????')])

    """ Environment """
    LOCATION = [
        ('hokkaido', '?????????'),
        ('tohoku', '??????'),
        ('kanto', '??????'),
        ('hokuriku', '??????'),
        ('chubu', '??????'),
        ('kansai', '??????'),
        ('chugoku', '??????'),
        ('shikoku', '??????'),
        ('kyushu', '??????'),
    ]
    location = models.CharField(verbose_name="???????????????", max_length=32, choices=LOCATION, blank=True, null=True)
    work = models.CharField(verbose_name="??????", max_length=20, blank=True, null=True)
    revenue = models.PositiveSmallIntegerField(verbose_name="??????", blank=True, null=True)
    GRADUATION = [
        ('junior_high_school', '??????'),
        ('high_school', '??????'),
        ('trade_school', '????????????????????????'),
        ('university', '??????'),
        ('grad_school', '????????????'),
    ]
    graduation = models.CharField(
        verbose_name="??????", max_length=32, choices=GRADUATION, blank=True, null=True)

    """ Appealing Point """
    hobby = models.CharField(
        verbose_name="??????", max_length=32, blank=True, null=True)
    PASSION = [
        ('hurry', '??????????????????'),
        ('speedy', '1????????????'),
        ('slowly', '????????????????????????'),
        ('no_marriage', '????????????????????????'),
    ]
    passion = models.CharField(
        verbose_name="????????????????????????", max_length=32, choices=PASSION, blank=True, null=True, default='slowly')
    tweet = models.CharField(verbose_name="????????????", max_length=10, blank=True, null=True)
    introduction = models.TextField(verbose_name="????????????", max_length=1000, blank=True, null=True)

    """ Assessment Fields """
    send_favorite = models.PositiveIntegerField(
        verbose_name="?????????????????????", blank=True, null=True, default=0)
    receive_favorite = models.PositiveIntegerField(
        verbose_name="????????????????????????", blank=True, null=True, default=0)
    stock_favorite = models.PositiveIntegerField(
        verbose_name="???????????????", blank=True, null=True, default=1000)

    class Meta:
        ordering = ['-created_at']

    def from_last_login(self):
        now_aware = datetime.now().astimezone()
        if self.user.last_login is None:
            return "?????????????????????"
        login_time: datetime = self.user.last_login
        if now_aware <= login_time + timedelta(days=1):
            return "24????????????"
        elif now_aware <= login_time + timedelta(days=2):
            return "2?????????"
        elif now_aware <= login_time + timedelta(days=3):
            return "3?????????"
        elif now_aware <= login_time + timedelta(days=7):
            return "1????????????"
        else:
            return "1????????????"

    def __str__(self):
        return self.nickname


class Matching(models.Model):

    approaching = models.ForeignKey(
        settings.AUTH_USER_MODEL, related_name='approaching',
        on_delete=models.CASCADE
    )
    approached = models.ForeignKey(
        settings.AUTH_USER_MODEL, related_name='approached',
        on_delete=models.CASCADE
    )
    approved = models.BooleanField(verbose_name="?????????????????????", default=False)
    created_at = models.DateTimeField(verbose_name="????????????", auto_now_add=True)

    class Meta:
        unique_together = (('approaching', 'approached'),)

    def __str__(self):
        return str(self.approaching) + ' --- like to ---> ' + str(self.approached)


class DirectMessage(models.Model):

    sender = models.ForeignKey(
        settings.AUTH_USER_MODEL, related_name='sender',
        on_delete=models.CASCADE
    )
    receiver = models.ForeignKey(
        settings.AUTH_USER_MODEL, related_name='receiver',
        on_delete=models.CASCADE
    )
    message = models.CharField(verbose_name="???????????????", max_length=200)
    created_at = models.DateTimeField(verbose_name="????????????", auto_now_add=True)

    def __str__(self):
        return str(self.sender) + ' --- send to ---> ' + str(self.receiver)
