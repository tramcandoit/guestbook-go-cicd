from locust import HttpUser, task, between

class LocustTest(HttpUser):
    wait_time = between(1, 5)
    @task
    def load_test_endpoint(self):
        self.client.get("/lrange/guestbook")