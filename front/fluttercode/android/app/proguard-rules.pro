# Manter as anotações do Error Prone
-keep class com.google.errorprone.annotations.** { *; }

# Manter anotações javax
-keep class javax.annotation.** { *; }

# Evitar remoção de classes relacionadas ao Google Tink
-keep class com.google.crypto.tink.** { *; }
