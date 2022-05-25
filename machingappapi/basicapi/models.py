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
        message = f'URLにアクセスして決済を完了してください。\n {settings.MY_URL}/api/users/{user_activate_token.token_id}/payment/'
    if instance.is_active:
        subject = 'Activated! Your Account!'
        message = 'ユーザーが使用できるようになりました'
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
    is_special = models.BooleanField(verbose_name="優良会員", default=False)
    is_kyc = models.BooleanField(verbose_name="本人確認", default=False)
    top_image = models.ImageField(
        verbose_name="トップ画像", upload_to=top_image_upload_path, blank=True, null=True)
    nickname = models.CharField(verbose_name="ニックネーム", max_length=20)
    created_at = models.DateTimeField(verbose_name="登録日時", auto_now_add=True)
    updated_at = models.DateTimeField(verbose_name="更新日時", auto_now=True, blank=True, null=True)

    """ Physical """
    age = models.PositiveSmallIntegerField(
        verbose_name="年齢", validators=[MinValueValidator(18, '18歳未満は登録できません'),
                                       MaxValueValidator(100, '100歳を超えて登録はできません')])
    SEX = [
        ('male', '男性'),
        ('female', '女性'),
    ]
    sex = models.CharField("性別", max_length=16, choices=SEX)
    height = models.PositiveSmallIntegerField(
        verbose_name="身長", blank=True, null=True,
        validators=[MinValueValidator(140, '140cm以上で入力してください'),
                    MaxValueValidator(200, '200cm以下で入力してください')])

    """ Environment """
    LOCATION = [
        ('hokkaido', '北海道'),
        ('tohoku', '東北'),
        ('kanto', '関東'),
        ('hokuriku', '北陸'),
        ('chubu', '中部'),
        ('kansai', '関西'),
        ('chugoku', '中国'),
        ('shikoku', '四国'),
        ('kyushu', '九州'),
    ]
    location = models.CharField(verbose_name="居住エリア", max_length=32, choices=LOCATION, blank=True, null=True)
    work = models.CharField(verbose_name="仕事", max_length=20, blank=True, null=True)
    revenue = models.PositiveSmallIntegerField(verbose_name="収入", blank=True, null=True)
    GRADUATION = [
        ('junior_high_school', '中卒'),
        ('high_school', '高卒'),
        ('trade_school', '短大・専門学校卒'),
        ('university', '大卒'),
        ('grad_school', '大学院卒'),
    ]
    graduation = models.CharField(
        verbose_name="学歴", max_length=32, choices=GRADUATION, blank=True, null=True)

    """ Appealing Point """
    hobby = models.CharField(
        verbose_name="趣味", max_length=32, blank=True, null=True)
    PASSION = [
        ('hurry', '今すぐにでも'),
        ('speedy', '1年以内に'),
        ('slowly', 'ゆっくり考えたい'),
        ('no_marriage', '結婚する気はない'),
    ]
    passion = models.CharField(
        verbose_name="結婚に対する熱意", max_length=32, choices=PASSION, blank=True, null=True, default='slowly')
    tweet = models.CharField(verbose_name="つぶやき", max_length=10, blank=True, null=True)
    introduction = models.TextField(verbose_name="自己紹介", max_length=1000, blank=True, null=True)

    """ Assessment Fields """
    send_favorite = models.PositiveIntegerField(
        verbose_name="送ったいいね数", blank=True, null=True, default=0)
    receive_favorite = models.PositiveIntegerField(
        verbose_name="もらったいいね数", blank=True, null=True, default=0)
    stock_favorite = models.PositiveIntegerField(
        verbose_name="いいね残数", blank=True, null=True, default=1000)

    class Meta:
        ordering = ['-created_at']

    def from_last_login(self):
        now_aware = datetime.now().astimezone()
        if self.user.last_login is None:
            return "ログイン歴なし"
        login_time: datetime = self.user.last_login
        if now_aware <= login_time + timedelta(days=1):
            return "24時間以内"
        elif now_aware <= login_time + timedelta(days=2):
            return "2日以内"
        elif now_aware <= login_time + timedelta(days=3):
            return "3日以内"
        elif now_aware <= login_time + timedelta(days=7):
            return "1週間以内"
        else:
            return "1週間以上"

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
    approved = models.BooleanField(verbose_name="マッチング許可", default=False)
    created_at = models.DateTimeField(verbose_name="登録日時", auto_now_add=True)

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
    message = models.CharField(verbose_name="メッセージ", max_length=200)
    created_at = models.DateTimeField(verbose_name="登録日時", auto_now_add=True)

    def __str__(self):
        return str(self.sender) + ' --- send to ---> ' + str(self.receiver)
