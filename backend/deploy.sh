#!/bin/bash
# Deploy Script - Vitta Backend
# Execute este script no servidor via SSH

echo "🚀 Iniciando deploy do Vitta Backend..."

# 1. Parar containers
echo "⏸️  Parando containers..."
cd /home/Vitta/backend
docker-compose down

# 2. Backup do banco (opcional, mas recomendado)
echo "💾 Fazendo backup do banco..."
docker run --rm \
  -v backend_postgres_data:/data \
  -v /tmp:/backup \
  busybox tar czf /backup/vitta_backup_$(date +%Y%m%d_%H%M%S).tar.gz /data

# 3. Remover volume antigo (ATENÇÃO: apaga dados!)
echo "🗑️  Removendo volume antigo..."
docker volume rm backend_postgres_data

# 4. Subir containers novamente
echo "🔄 Recriando containers..."
docker-compose up -d --build

# 5. Aguardar inicialização
echo "⏳ Aguardando inicialização (15s)..."
sleep 15

# 6. Popular com dados mockados
echo "🌱 Populando banco com dados mockados..."
docker-compose exec -T api python seed_mock.py

# 7. Verificar status
echo "✅ Verificando status..."
docker ps
docker-compose logs --tail=20 api

echo ""
echo "🎉 Deploy concluído!"
echo "📊 Teste a API: curl http://localhost:8000/health"
