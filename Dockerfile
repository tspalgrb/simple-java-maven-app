FROM amazoncorretto:17-alpine3.18
WORKDIR /app
COPY ./target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]