# flutter_local_notifications は Gson の TypeToken を使う。R8 がジェネリック署名を
# 削除すると zonedSchedule が "TypeToken must be created with a type argument" で失敗する。
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.dexterous.** { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep class com.google.gson.reflect.TypeToken { *; }
