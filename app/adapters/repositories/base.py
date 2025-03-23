from abc import ABC, abstractmethod

from sqlalchemy.orm import Session


class AbstractPostgresRepository(ABC):
    def __init__(self, session: Session):
        self.session = session

    @abstractmethod
    def create(self, *args, **kwargs):
        raise NotImplemented
