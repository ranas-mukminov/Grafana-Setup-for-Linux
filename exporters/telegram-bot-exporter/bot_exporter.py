"""
Prometheus exporter для Telegram ботов
Автор: run-as-daemon.ru

Пример использования с aiogram 3.x:

from aiogram import Bot, Dispatcher
from bot_exporter import PrometheusMiddleware, start_metrics_server

# Запускаем HTTP сервер для метрик
start_metrics_server(8000)

# Создаем бота
bot = Bot(token="YOUR_TOKEN")
dp = Dispatcher()

# Подключаем middleware
dp.update.middleware(PrometheusMiddleware('my_bot'))

# Запускаем бота
dp.run_polling(bot)
"""

from prometheus_client import start_http_server, Counter, Gauge, Histogram
import time
import logging
from typing import Callable, Dict, Any, Awaitable

# Настройка логирования
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Метрики
bot_messages_total = Counter(
    'telegram_bot_messages_total',
    'Total messages processed by bot',
    ['bot_name', 'chat_type']
)

bot_commands_total = Counter(
    'telegram_bot_commands_total',
    'Total commands processed',
    ['bot_name', 'command']
)

bot_errors_total = Counter(
    'telegram_bot_errors_total',
    'Total errors',
    ['bot_name', 'error_type']
)

bot_active_users = Gauge(
    'telegram_bot_active_users',
    'Number of active users',
    ['bot_name']
)

bot_processing_time = Histogram(
    'telegram_bot_processing_seconds',
    'Time spent processing messages',
    ['bot_name']
)

bot_api_calls = Counter(
    'telegram_bot_api_calls_total',
    'Total Telegram API calls',
    ['bot_name', 'method']
)

bot_message_size = Histogram(
    'telegram_bot_message_size_bytes',
    'Size of messages in bytes',
    ['bot_name']
)


class PrometheusMiddleware:
    """
    Middleware для aiogram для сбора метрик
    
    Использование:
        from aiogram import Dispatcher
        dp = Dispatcher()
        dp.update.middleware(PrometheusMiddleware('my_bot'))
    """
    
    def __init__(self, bot_name: str):
        self.bot_name = bot_name
        logger.info(f"PrometheusMiddleware initialized for bot: {bot_name}")
        
    async def __call__(
        self,
        handler: Callable[[Any, Dict[str, Any]], Awaitable[Any]],
        event: Any,
        data: Dict[str, Any]
    ) -> Any:
        start_time = time.time()
        
        try:
            # Определяем тип чата
            chat_type = 'unknown'
            if hasattr(event, 'message') and event.message:
                chat_type = event.message.chat.type
            elif hasattr(event, 'chat'):
                chat_type = event.chat.type
            
            # Считаем сообщение
            bot_messages_total.labels(
                bot_name=self.bot_name,
                chat_type=chat_type
            ).inc()
            
            # Если это команда
            text = None
            if hasattr(event, 'message') and event.message and event.message.text:
                text = event.message.text
            elif hasattr(event, 'text'):
                text = event.text
                
            if text and text.startswith('/'):
                command = text.split()[0]
                bot_commands_total.labels(
                    bot_name=self.bot_name,
                    command=command
                ).inc()
            
            # Размер сообщения
            if text:
                message_size = len(text.encode('utf-8'))
                bot_message_size.labels(bot_name=self.bot_name).observe(message_size)
            
            # Вызываем handler
            result = await handler(event, data)
            
            # Замеряем время обработки
            processing_time = time.time() - start_time
            bot_processing_time.labels(bot_name=self.bot_name).observe(processing_time)
            
            return result
            
        except Exception as e:
            # Считаем ошибки
            bot_errors_total.labels(
                bot_name=self.bot_name,
                error_type=type(e).__name__
            ).inc()
            logger.error(f"Error in middleware: {e}", exc_info=True)
            raise


def track_api_call(bot_name: str, method: str):
    """Декоратор для отслеживания API вызовов"""
    def decorator(func):
        def wrapper(*args, **kwargs):
            bot_api_calls.labels(
                bot_name=bot_name,
                method=method
            ).inc()
            return func(*args, **kwargs)
        return wrapper
    return decorator


def update_active_users(bot_name: str, count: int):
    """Обновить количество активных пользователей"""
    bot_active_users.labels(bot_name=bot_name).set(count)


def start_metrics_server(port: int = 8000):
    """Запустить HTTP сервер для метрик"""
    try:
        start_http_server(port)
        logger.info(f"📊 Prometheus exporter started on port {port}")
        logger.info(f"📈 Metrics available at http://localhost:{port}/metrics")
        return True
    except Exception as e:
        logger.error(f"Failed to start metrics server: {e}")
        return False


# Пример использования
if __name__ == '__main__':
    # Запускаем HTTP сервер для метрик
    start_metrics_server(8000)
    
    logger.info("Telegram Bot Exporter is running...")
    logger.info("Integrate this with your bot using PrometheusMiddleware")
    logger.info("Example:")
    logger.info("  from bot_exporter import PrometheusMiddleware, start_metrics_server")
    logger.info("  start_metrics_server(8000)")
    logger.info("  dp.update.middleware(PrometheusMiddleware('my_bot'))")
    
    # Держим процесс запущенным
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        logger.info("Shutting down...")
