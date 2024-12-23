package com.web.Portfolio.MongoDB;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.view.RedirectView;

@RestController
@RequestMapping("/api/forms")
public class MessageController {

    @Autowired
    private MessageService messageService;

    // Handles JSON requests
    @PostMapping(consumes = "application/json")
    public ResponseEntity<String> submitFormJson(@RequestBody Message message) {
        if (message.getFullname() == null || message.getEmail() == null || message.getMessage() == null) {
            return ResponseEntity.badRequest().body("All fields are required");
        }
        messageService.saveMessage(message);
        return ResponseEntity.ok("Message sent successfully!");
    }

    // Handles plain text requests (application/x-www-form-urlencoded)
    @PostMapping(consumes = "text/plain")
    public ResponseEntity<String> submitMessageString(@RequestBody String messageText) {
        Message message = new Message();
        message.setMessage(messageText);  // Set the message field
        // Optionally set other fields if required
        messageService.saveMessage(message);
        return ResponseEntity.ok("Message sent successfully!");
    }

    // Handles form-urlencoded requests (application/x-www-form-urlencoded)
    @PostMapping(consumes = "application/x-www-form-urlencoded")
    public RedirectView submitFormUrlEncoded(@RequestParam String fullname,
                                             @RequestParam String email,
                                             @RequestParam String message) {
        Message msg = new Message();
        msg.setFullname(fullname);
        msg.setEmail(email);
        msg.setMessage(message);
        messageService.saveMessage(msg);
        return new RedirectView("/");  // Redirect to the index page after success
    }

    @GetMapping("/{id}")
    public ResponseEntity<Message> getMessage(@PathVariable String id) {
        return messageService.getMessageById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
