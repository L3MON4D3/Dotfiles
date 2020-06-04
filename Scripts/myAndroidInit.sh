cp ~/Documents/Templates/androidTemplate/templ/* . -r
sed -i 's/helloworld/'"$1"'/g' gradle.properties app/src/main/AndroidManifest.xml app/src/main/java/MainActivity.java
