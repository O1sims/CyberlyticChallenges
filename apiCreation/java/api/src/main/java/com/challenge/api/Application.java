package com.challenge.api;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import com.challenge.api.models.Person;
import com.challenge.api.services.PersonService;

@SpringBootApplication
public class Application {

	public static void main(String[] args) {
		SpringApplication.run(Application.class, args);
	}
	
	@Bean
    public CommandLineRunner commandLineRunner(
    		ApplicationContext ctx, 
    		PersonService personService) {
        return args -> {
            System.out.println("Saving people...");
            ObjectMapper mapper = new ObjectMapper();
			TypeReference<List<Person>> personTypeReference = new TypeReference<List<Person>>(){};
			InputStream personInputStream = TypeReference.class.getResourceAsStream("/data/people.json");
			try {
				List<Person> people = mapper.readValue(personInputStream, personTypeReference);
				personService.dropPeople();
				personService.save(people);
				System.out.println("People saved!");
			} catch (IOException e) {
				System.out.println("Unable to save people data: " + e.getMessage());
			};
        };
    }
}
